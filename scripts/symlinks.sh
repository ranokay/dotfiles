#!/usr/bin/env bash

# Create symlinks for dotfiles configuration files

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$DOTFILES_DIR/config"

# List of dotfiles to symlink (source:target pairs)
DOTFILES=(
    # Shell configurations
    "$CONFIG_DIR/.zshrc:$HOME/.zshrc"
    # Add more dotfiles here in the future
    # "$CONFIG_DIR/.bashrc:$HOME/.bashrc"
    # "$CONFIG_DIR/.gitconfig:$HOME/.gitconfig"
)

create_symlinks() {
    print_step "Creating Dotfile Symlinks"
    print_info "Linking configuration files..."

    local linked_count=0
    local skipped_count=0
    local backed_up_count=0
    local total_files=${#DOTFILES[@]}

    for dotfile_pair in "${DOTFILES[@]}"; do
        # Split source:target pair
        local source_path="${dotfile_pair%%:*}"
        local target_path="${dotfile_pair##*:}"
        local file_name=$(basename "$target_path")

        print_substep "Processing $file_name"

        # Check if source exists
        if [[ ! -f "$source_path" ]]; then
            print_warning "Source file not found: $source_path"
            ((skipped_count++))
            continue
        fi

        # Handle existing files/symlinks
        if [[ -L "$target_path" ]]; then
            # It's a symlink
            local current_target=$(readlink "$target_path")
            if [[ "$current_target" == "$source_path" ]]; then
                print_success "✓ $file_name already linked correctly"
                ((skipped_count++))
                continue
            else
                print_info "Updating existing symlink: $file_name"
                if [[ "$DRY_RUN" != "true" ]]; then
                    rm "$target_path"
                fi
            fi
        elif [[ -f "$target_path" ]]; then
            # It's a regular file
            print_warning "Existing file found: $file_name"

            if [[ "$DRY_RUN" == "true" ]]; then
                print_dry_run "Would backup $file_name to ${file_name}.backup"
            else
                if prompt_with_default "Backup existing $file_name and replace with symlink?" "y"; then
                    local backup_path="${target_path}.backup.$(date +%Y%m%d_%H%M%S)"
                    if cp "$target_path" "$backup_path"; then
                        print_success "Backed up to: $(basename "$backup_path")"
                        rm "$target_path"
                        ((backed_up_count++))
                    else
                        handle_warning "Failed to backup $file_name" "Skipping this file"
                        ((skipped_count++))
                        continue
                    fi
                else
                    print_info "Skipped: $file_name"
                    ((skipped_count++))
                    continue
                fi
            fi
        fi

        # Create the symlink
        if [[ "$DRY_RUN" == "true" ]]; then
            print_dry_run "Would create symlink: $target_path -> $source_path"
            ((linked_count++))
        else
            if ln -s "$source_path" "$target_path"; then
                print_success "Linked: $file_name -> $source_path"
                ((linked_count++))
            else
                handle_warning "Failed to create symlink for $file_name" "Check permissions and try again"
                ((skipped_count++))
            fi
        fi
    done

    # Summary
    echo ""
    print_step "Symlink Summary"
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Dry-run results:"
    fi
    print_success "Linked: $linked_count file(s)"
    if [[ $backed_up_count -gt 0 ]]; then
        print_info "Backed up: $backed_up_count file(s)"
    fi
    if [[ $skipped_count -gt 0 ]]; then
        print_info "Skipped: $skipped_count file(s)"
    fi

    echo ""
    print_success "Dotfile symlinks configuration complete!"

    if [[ $linked_count -gt 0 ]] && [[ "$DRY_RUN" != "true" ]]; then
        echo ""
        print_info "💡 Tip: Reload your shell to apply changes"
        print_info "   Run: exec \$SHELL"
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_symlinks
fi

