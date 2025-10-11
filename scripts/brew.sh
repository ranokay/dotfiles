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

    # Check for issues (optional health check) - with timeout
    print_info "Checking Homebrew installation health..."
    local doctor_output
    local doctor_exit_code=0

    # Run brew doctor with a timeout to prevent hanging (using perl for macOS compatibility)
    if doctor_output=$(perl -e 'alarm shift @ARGV; exec @ARGV' 10 brew doctor 2>&1); then
        print_success "Homebrew health check passed"
    else
        doctor_exit_code=$?
        if [[ $doctor_exit_code -eq 142 ]] || [[ $doctor_exit_code -eq 124 ]]; then
            print_warning "Homebrew health check timed out (not critical)"
            print_info "Run 'brew doctor' manually if you want to check for issues"
        elif [[ $doctor_exit_code -ne 0 ]]; then
            print_warning "Homebrew doctor found some issues:"
            echo "$doctor_output" | head -10 2>/dev/null || true
            print_info "These issues may not be critical - continuing anyway"
            print_info "Run 'brew doctor' manually to see full report"
        fi
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

    # Show what needs to be installed/updated
    print_substep "Analyzing package requirements..."
    local check_output
    check_output=$(brew bundle check --file="$brewfile" --verbose 2>&1 || true)

    # Count packages that need action
    local missing_count=$(echo "$check_output" | grep -c "needs to be installed" 2>/dev/null || echo "0")

    if [[ $missing_count -gt 0 ]]; then
        print_info "Found $missing_count package(s) to install/update"
        echo ""
    else
        print_success "All packages from Brewfile are already installed"
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
        print_substep "Installing/updating packages (this may take a while)..."
        echo ""

        local bundle_exit_code=0
        local temp_log="$(mktemp)"

        # Show real-time progress by piping through a processor
        # This will show brew's output live while also capturing it
        # Track what we've already shown to avoid duplicates
        declare -A shown_packages

        (
            brew bundle --file="$brewfile" --verbose 2>&1 | tee "$temp_log" | while IFS= read -r line; do
                # Skip generic brew messages that aren't about specific packages
                if [[ "$line" =~ ^Installing\ (Cask|dependencies|formula) ]] || \
                   [[ "$line" =~ ^Using\ (Cask|dependencies|formula) ]] || \
                   [[ "$line" =~ ^Upgrading\ (Cask|dependencies|formula) ]]; then
                    continue
                fi

                case "$line" in
                    "Installing "*)
                        # Only show if it's "Installing <package>" format (not "Installing Cask" etc)
                        if [[ "$line" =~ ^Installing\ ([a-zA-Z0-9_@.+-]+)$ ]]; then
                            local pkg="${BASH_REMATCH[1]}"
                            # Only show if we haven't shown this package yet
                            if [[ -z "${shown_packages[$pkg]}" ]]; then
                                printf "${BLUE}  📦 Installing${NC} ${GREEN}%s${NC}\n" "$pkg"
                                shown_packages[$pkg]=1
                            fi
                        fi
                        ;;
                    "Upgrading "*)
                        if [[ "$line" =~ ^Upgrading\ ([a-zA-Z0-9_@.+-]+)$ ]]; then
                            local pkg="${BASH_REMATCH[1]}"
                            if [[ -z "${shown_packages[$pkg]}" ]]; then
                                printf "${BLUE}  ⬆️  Upgrading${NC} ${GREEN}%s${NC}\n" "$pkg"
                                shown_packages[$pkg]=1
                            fi
                        fi
                        ;;
                    "Using "*)
                        if [[ "$line" =~ ^Using\ ([a-zA-Z0-9_@.+-]+)$ ]]; then
                            local pkg="${BASH_REMATCH[1]}"
                            if [[ -z "${shown_packages[$pkg]}" ]]; then
                                printf "${YELLOW}  ✓ Using${NC} ${GREEN}%s${NC}\n" "$pkg"
                                shown_packages[$pkg]=1
                            fi
                        fi
                        ;;
                    "Tapping "*)
                        if [[ "$line" =~ ^Tapping\ ([a-zA-Z0-9_/@.+-]+)$ ]]; then
                            local tap="${BASH_REMATCH[1]}"
                            printf "${MAGENTA}  🔗 Tapping${NC} ${GREEN}%s${NC}\n" "$tap"
                        fi
                        ;;
                esac
            done
        ) || bundle_exit_code=$?

        echo ""

        if [[ $bundle_exit_code -ne 0 ]]; then
            print_error "Failed to install some packages (exit code: $bundle_exit_code)"
            echo ""
            print_info "Last 20 lines of output:"
            tail -20 "$temp_log"
            echo ""
            print_info "Full log available at: $LOG_FILE"
            rm -f "$temp_log"
            exit 1
        fi

        # Count what was installed from the captured log
        local installed_count=$(grep -c "Installing" "$temp_log" 2>/dev/null || echo "0")
        local upgraded_count=$(grep -c "Upgrading" "$temp_log" 2>/dev/null || echo "0")
        local using_count=$(grep -c "Using" "$temp_log" 2>/dev/null || echo "0")

        # Log full output to file
        cat "$temp_log" >> "$LOG_FILE"
        rm -f "$temp_log"

        print_substep "Summary:"
        if [[ $installed_count -gt 0 ]]; then
            print_success "  Installed: $installed_count package(s)"
        fi
        if [[ $upgraded_count -gt 0 ]]; then
            print_success "  Upgraded: $upgraded_count package(s)"
        fi
        if [[ $using_count -gt 0 ]]; then
            print_info "  Already installed: $using_count package(s)"
        fi

        if [[ $installed_count -eq 0 ]] && [[ $upgraded_count -eq 0 ]]; then
            print_success "All packages already up to date"
        fi
    fi

    # Post-installation tasks
    print_step "Post-Installation Tasks"
    manage_services
    check_outdated
    cleanup_homebrew

    # Final completion message
    echo ""
    print_success "Package management completed successfully!"
    print_info "All packages are installed and configured"
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
