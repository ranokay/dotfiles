#!/usr/bin/env bash
# Requires Bash 4+ for associative arrays
# Run with: /usr/local/bin/bash or /opt/homebrew/bin/bash

# Backup and restore functionality for macOS defaults

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

BACKUP_DIR="${HOME}/.dotfiles-backup"
BACKUP_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CURRENT_BACKUP_DIR="${BACKUP_DIR}/${BACKUP_TIMESTAMP}"

# Check Bash version - need 4.0+ for associative arrays
if [[ ${BASH_VERSION%%.*} -lt 4 ]]; then
    print_warning "Backup requires Bash 4+, currently running Bash $BASH_VERSION"
    print_info "Backup will be skipped on this run. After Homebrew installs Bash 4+, backups will work."
    BACKUP_AVAILABLE=false
else
    BACKUP_AVAILABLE=true
fi

# List of domains and keys to backup (Bash 4+ associative arrays)
declare -A BACKUP_SETTINGS=(
    # General settings
    ["NSGlobalDomain::NSUseAnimatedFocusRing"]="focus ring animation"
    ["NSGlobalDomain::NSAutomaticCapitalizationEnabled"]="automatic capitalization"
    ["NSGlobalDomain::NSAutomaticDashSubstitutionEnabled"]="smart dashes"
    ["NSGlobalDomain::NSAutomaticPeriodSubstitutionEnabled"]="automatic period substitution"
    ["NSGlobalDomain::NSAutomaticQuoteSubstitutionEnabled"]="smart quotes"
    ["NSGlobalDomain::NSAutomaticSpellingCorrectionEnabled"]="auto-correct"
    ["NSGlobalDomain::AppleActionOnDoubleClick"]="double click action"
    ["NSGlobalDomain::KeyRepeat"]="key repeat rate"
    ["NSGlobalDomain::InitialKeyRepeat"]="initial key repeat delay"

    # Finder settings
    ["com.apple.finder::DisableAllAnimations"]="Finder animations"
    ["com.apple.finder::NewWindowTarget"]="new Finder window location"
    ["com.apple.finder::AppleShowAllFiles"]="show hidden files"
    ["com.apple.finder::ShowStatusBar"]="Finder status bar"
    ["com.apple.finder::ShowPathbar"]="Finder path bar"

    # Dock settings
    ["com.apple.dock::autohide"]="Dock autohide"
    ["com.apple.dock::autohide-delay"]="Dock autohide delay"
    ["com.apple.dock::tilesize"]="Dock icon size"
    ["com.apple.dock::magnification"]="Dock magnification"
    ["com.apple.dock::show-process-indicators"]="Dock process indicators"
)

# Create backup directory
create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        print_info "Created backup directory: $BACKUP_DIR"
    fi

    mkdir -p "$CURRENT_BACKUP_DIR"
    print_success "Created backup: $CURRENT_BACKUP_DIR"
}

# Backup current settings
backup_settings() {
    # Skip if Bash version too old
    if [[ "$BACKUP_AVAILABLE" == "false" ]]; then
        print_info "Skipping backup (Bash 4+ required)"
        return 0
    fi

    print_info "Creating backup of current settings..."

    create_backup_dir

    local backup_count=0
    local total_settings=${#BACKUP_SETTINGS[@]}

    # Create backup metadata
    cat > "$CURRENT_BACKUP_DIR/metadata.txt" << EOF
Backup created: $(date)
macOS version: $(sw_vers -productVersion)
Script version: dotfiles-backup-v1.0
Total settings: $total_settings
EOF

    # Backup system configuration
    {
        echo "# System Configuration"
        echo "ComputerName=$(scutil --get ComputerName 2>/dev/null || echo 'NOT_SET')"
        echo "HostName=$(scutil --get HostName 2>/dev/null || echo 'NOT_SET')"
        echo "LocalHostName=$(scutil --get LocalHostName 2>/dev/null || echo 'NOT_SET')"
    } > "$CURRENT_BACKUP_DIR/system_config.txt"

    # Backup defaults settings
    for setting_key in "${!BACKUP_SETTINGS[@]}"; do
        ((backup_count++))
        local domain="${setting_key%%::*}"
        local key="${setting_key##*::}"
        local description="${BACKUP_SETTINGS[$setting_key]}"

        print_progress "$backup_count" "$total_settings" "Backing up $description"

        local value
        value=$(defaults read "$domain" "$key" 2>/dev/null || echo "NOT_SET")

        # Store in backup file
        echo "${domain}::${key}=${value}" >> "$CURRENT_BACKUP_DIR/defaults.txt"
    done

    # Backup Homebrew packages
    if command_exists brew; then
        print_info "Backing up Homebrew packages..."
        brew bundle dump --file="$CURRENT_BACKUP_DIR/Brewfile.backup" --force

        # List installed packages
        {
            echo "# Homebrew Formulae"
            brew list --formula
            echo ""
            echo "# Homebrew Casks"
            brew list --cask
            echo ""
            echo "# Mac App Store Apps"
            mas list 2>/dev/null || echo "mas not available"
        } > "$CURRENT_BACKUP_DIR/installed_packages.txt"
    fi

    print_success "Backup completed: $CURRENT_BACKUP_DIR"

    # Clean up old backups (keep last 5)
    cleanup_old_backups
}

# Restore settings from backup
restore_settings() {
    local backup_dir="$1"

    if [[ ! -d "$backup_dir" ]]; then
        print_error "Backup directory not found: $backup_dir"
        return 1
    fi

    if [[ ! -f "$backup_dir/defaults.txt" ]]; then
        print_error "Backup file not found: $backup_dir/defaults.txt"
        return 1
    fi

    print_info "Restoring settings from: $backup_dir"

    local restore_count=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^([^:]+)::([^=]+)=(.*)$ ]]; then
            local domain="${BASH_REMATCH[1]}"
            local key="${BASH_REMATCH[2]}"
            local value="${BASH_REMATCH[3]}"

            ((restore_count++))

            if [[ "$value" == "NOT_SET" ]]; then
                print_info "[$restore_count] Removing $domain $key (was not set in backup)"
                if [[ "$DRY_RUN" != "true" ]]; then
                    defaults delete "$domain" "$key" 2>/dev/null || true
                fi
            else
                print_info "[$restore_count] Restoring $domain $key = $value"
                if [[ "$DRY_RUN" != "true" ]]; then
                    # Determine value type and restore appropriately
                    if [[ "$value" =~ ^[0-9]+$ ]]; then
                        defaults write "$domain" "$key" -int "$value"
                    elif [[ "$value" =~ ^[0-9]+\.[0-9]+$ ]]; then
                        defaults write "$domain" "$key" -float "$value"
                    elif [[ "$value" == "1" ]] || [[ "$value" == "0" ]]; then
                        defaults write "$domain" "$key" -bool "$([[ $value == "1" ]] && echo true || echo false)"
                    else
                        defaults write "$domain" "$key" -string "$value"
                    fi
                fi
            fi
        fi
    done < "$backup_dir/defaults.txt"

    # Restore system configuration
    if [[ -f "$backup_dir/system_config.txt" ]]; then
        print_info "Restoring system configuration..."
        while IFS= read -r line; do
            if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
                local config_type="${BASH_REMATCH[1]}"
                local config_value="${BASH_REMATCH[2]}"

                if [[ "$config_value" != "NOT_SET" ]]; then
                    print_info "Restoring $config_type = $config_value"
                    if [[ "$DRY_RUN" != "true" ]]; then
                        sudo scutil --set "$config_type" "$config_value"
                    fi
                fi
            fi
        done < <(grep -v "^#" "$backup_dir/system_config.txt")
    fi

    print_success "Settings restored from backup"
}

# List available backups
list_backups() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        print_info "No backups found. Backup directory doesn't exist."
        return 0
    fi

    print_info "Available backups:"

    local backup_dirs=()
    while IFS= read -r -d '' dir; do
        backup_dirs+=("$dir")
    done < <(find "$BACKUP_DIR" -maxdepth 1 -type d -name "20*" -print0 | sort -z)

    if [[ ${#backup_dirs[@]} -eq 0 ]]; then
        print_info "No backups found."
        return 0
    fi

    for backup_dir in "${backup_dirs[@]}"; do
        local timestamp=$(basename "$backup_dir")
        local formatted_date=$(echo "$timestamp" | sed 's/_/ /' | sed 's/\\(....\\.\\..\\..\\) \\(..\\)\\(..\\)\\(..\\)/\\1 \\2:\\3:\\4/')

        if [[ -f "$backup_dir/metadata.txt" ]]; then
            local settings_count=$(grep "Total settings:" "$backup_dir/metadata.txt" | cut -d':' -f2 | xargs)
            printf "  %s (%s settings)\\n" "$formatted_date" "$settings_count"
        else
            printf "  %s\\n" "$formatted_date"
        fi

        echo "    Path: $backup_dir"
    done
}

# Clean up old backups (keep last 5)
cleanup_old_backups() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        return 0
    fi

    local backup_dirs=()
    while IFS= read -r -d '' dir; do
        backup_dirs+=("$dir")
    done < <(find "$BACKUP_DIR" -maxdepth 1 -type d -name "20*" -print0 | sort -rz)

    if [[ ${#backup_dirs[@]} -gt 5 ]]; then
        print_info "Cleaning up old backups (keeping 5 most recent)..."
        for ((i=5; i<${#backup_dirs[@]}; i++)); do
            local old_backup="${backup_dirs[i]}"
            print_info "Removing old backup: $(basename "$old_backup")"
            rm -rf "$old_backup"
        done
        print_success "Cleaned up $((${#backup_dirs[@]} - 5)) old backups"
    fi
}

# Main function for command-line usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        "backup")
            backup_settings
            ;;
        "restore")
            if [[ -z "${2:-}" ]]; then
                print_error "Please specify backup directory or timestamp"
                print_info "Usage: $0 restore <backup_timestamp>"
                print_info "Use '$0 list' to see available backups"
                exit 1
            fi

            # Allow restoring by timestamp
            if [[ "$2" =~ ^[0-9]{8}_[0-9]{6}$ ]]; then
                restore_dir="$BACKUP_DIR/$2"
            else
                restore_dir="$2"
            fi

            restore_settings "$restore_dir"
            ;;
        "list")
            list_backups
            ;;
        *)
            echo "Usage: $0 {backup|restore <timestamp>|list}"
            echo ""
            echo "Examples:"
            echo "  $0 backup                    # Create backup"
            echo "  $0 list                      # List available backups"
            echo "  $0 restore 20231010_143022   # Restore from timestamp"
            exit 1
            ;;
    esac
fi