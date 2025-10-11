#!/usr/bin/env bash

# Shell configuration management for dotfiles

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$DOTFILES_DIR/config"

# Shell configurations to manage (source:target pairs)
SHELL_CONFIGS=(
    # Zsh configurations
    "$CONFIG_DIR/shell/zshrc:.zshrc"
    "$CONFIG_DIR/shell/zsh_aliases:.zsh_aliases"
    "$CONFIG_DIR/shell/zshenv:.zshenv"

    # Fish configurations
    "$CONFIG_DIR/shell/config.fish:.config/fish/config.fish"

    # Development configurations
    "$CONFIG_DIR/vim/vimrc:.vimrc"
    "$CONFIG_DIR/tmux/tmux.conf:.tmux.conf"
)

# Create config directories if they don't exist
create_config_directories() {
    local directories=(
        "$CONFIG_DIR/shell"
        "$CONFIG_DIR/git"
        "$CONFIG_DIR/vim"
        "$CONFIG_DIR/tmux"
        "$HOME/.config/fish"
        "$HOME/.config/fish/functions"
    )

    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                print_dry_run "Would create directory: $dir"
            else
                mkdir -p "$dir"
                print_success "Created directory: $dir"
            fi
        fi
    done
}

# Detect current shell
detect_shell() {
    local current_shell="$SHELL"
    local shell_name=""

    case "$current_shell" in
        */zsh)
            shell_name="zsh"
            ;;
        */bash)
            shell_name="bash"
            ;;
        */fish)
            shell_name="fish"
            ;;
        *)
            shell_name="unknown"
            ;;
    esac

    print_info "Current shell: $shell_name ($current_shell)"
    echo "$shell_name"
}

# Create default shell configurations
create_default_configs() {
    print_info "Creating default shell configurations..."

    create_config_directories

    # Create default .zshrc
    if [[ ! -f "$CONFIG_DIR/shell/zshrc" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_dry_run "Would create default .zshrc configuration"
        else
            cat > "$CONFIG_DIR/shell/zshrc" << 'EOF'
# Zsh configuration for dotfiles

# Oh My Zsh installation path
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    brew
    macos
    zsh-autosuggestions
    zsh-syntax-highlighting
    fast-syntax-highlighting
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load custom aliases
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases

# Homebrew setup
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Node Version Manager
if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd)"
fi

# 1Password SSH Agent
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Custom PATH additions
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR="code"
export VISUAL="$EDITOR"
EOF
            print_success "Created default .zshrc"
        fi
    fi

    # Create default aliases
    if [[ ! -f "$CONFIG_DIR/shell/zsh_aliases" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_dry_run "Would create default shell aliases"
        else
            cat > "$CONFIG_DIR/shell/zsh_aliases" << 'EOF'
# Custom aliases for dotfiles

# Better ls
if command -v eza >/dev/null 2>&1; then
    alias ls="eza --icons"
    alias ll="eza -l --icons --git"
    alias la="eza -la --icons --git"
    alias tree="eza --tree --icons"
fi

# Better cat
if command -v bat >/dev/null 2>&1; then
    alias cat="bat"
fi

# Git aliases
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gb="git branch"
alias gco="git checkout"

# Directory shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Development
alias brewup="brew update && brew upgrade"
alias dotfiles="cd $HOME/dotfiles"

# System
alias reload="exec $SHELL"
alias path='echo $PATH | tr ":" "\n"'

# Docker (if using OrbStack)
alias docker-clean="docker system prune -af"
EOF
            print_success "Created default aliases"
        fi
    fi

    # Create Fish config
    if [[ ! -f "$CONFIG_DIR/shell/config.fish" ]] && command -v fish >/dev/null 2>&1; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_dry_run "Would create Fish shell configuration"
        else
            cat > "$CONFIG_DIR/shell/config.fish" << 'EOF'
# Fish configuration for dotfiles

# Disable greeting
set fish_greeting

# Homebrew setup
if test -f "/opt/homebrew/bin/brew"
    eval (/opt/homebrew/bin/brew shellenv)
else if test -f "/usr/local/bin/brew"
    eval (/usr/local/bin/brew shellenv)
end

# Node Version Manager
if command -v fnm >/dev/null 2>&1
    fnm env --use-on-cd | source
end

# 1Password SSH Agent
set -x SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Editor
set -x EDITOR code
set -x VISUAL $EDITOR

# PATH
set -x PATH $HOME/.local/bin $PATH

# Aliases
if command -v eza >/dev/null 2>&1
    alias ls "eza --icons"
    alias ll "eza -l --icons --git"
    alias la "eza -la --icons --git"
end

if command -v bat >/dev/null 2>&1
    alias cat "bat"
end
EOF
            print_success "Created Fish config"
        fi
    fi
}

# Link configuration files
link_configs() {
    print_info "Linking shell configurations..."

    local linked_count=0
    local total_configs=${#SHELL_CONFIGS[@]}

    for config_pair in "${SHELL_CONFIGS[@]}"; do
        ((linked_count++))

        # Split source:target pair
        local source_path="${config_pair%%:*}"
        local target_path="${config_pair##*:}"
        local full_target_path="$HOME/$target_path"

        print_progress "$linked_count" "$total_configs" "Processing $target_path"

        # Create target directory if needed
        local target_dir
        target_dir=$(dirname "$full_target_path")
        if [[ ! -d "$target_dir" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                print_dry_run "Would create directory: $target_dir"
            else
                mkdir -p "$target_dir"
            fi
        fi

        # Skip if source doesn't exist
        if [[ ! -e "$source_path" ]] && [[ ! -d "$source_path" ]]; then
            print_info "Skipping $target_path (source not found: $source_path)"
            continue
        fi

        # Handle existing files/links
        if [[ -e "$full_target_path" ]] || [[ -L "$full_target_path" ]]; then
            if [[ -L "$full_target_path" ]]; then
                local current_target
                current_target=$(readlink "$full_target_path")
                if [[ "$current_target" == "$source_path" ]]; then
                    print_info "✓ $target_path already linked correctly"
                    continue
                fi
                print_info "Updating symlink: $target_path"
            else
                print_info "Backing up existing file: $target_path"
                if [[ "$DRY_RUN" != "true" ]]; then
                    # Add to rollback stack
                    add_to_rollback "file" "restore $target_path" "cp '$full_target_path.backup' '$full_target_path'"
                    mv "$full_target_path" "$full_target_path.backup"
                fi
            fi
        fi

        # Create symlink
        if [[ "$DRY_RUN" == "true" ]]; then
            print_dry_run "Would link $target_path -> $source_path"
        else
            # Add to rollback stack
            add_to_rollback "file" "remove symlink $target_path" "rm '$full_target_path'"

            if ln -sf "$source_path" "$full_target_path"; then
                print_success "Linked $target_path -> $source_path"
            else
                handle_error 1 "Failed to create symlink: $target_path" "true"
            fi
        fi
    done
}

# Configure shell-specific settings
configure_shell_specifics() {
    local shell_name
    shell_name=$(detect_shell)

    case "$shell_name" in
        "zsh")
            configure_zsh
            ;;
        "fish")
            configure_fish
            ;;
        "bash")
            configure_bash
            ;;
        *)
            print_info "Shell-specific configuration not available for: $shell_name"
            ;;
    esac
}

# Configure Zsh with Oh My Zsh
configure_zsh() {
    print_info "Configuring Zsh..."

    # Install Oh My Zsh if not present
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_dry_run "Would install Oh My Zsh"
        else
            print_info "Installing Oh My Zsh..."

            # Check if git is available
            if ! command_exists git; then
                handle_error 1 "Git is required to install Oh My Zsh" "false" "Install Git first: brew install git"
                return 1
            fi

            if ! RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 2>&1; then
                handle_error 1 "Failed to install Oh My Zsh" "true" "Check your internet connection or install manually"
            else
                print_success "Oh My Zsh installed"
            fi
        fi
    fi

    # Install Powerlevel10k theme
    local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [[ ! -d "$p10k_dir" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_dry_run "Would install Powerlevel10k theme"
        else
            print_info "Installing Powerlevel10k theme..."
            if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir" 2>&1; then
                handle_warning "Failed to install Powerlevel10k theme" "Install it manually or check your internet connection"
            else
                print_success "Powerlevel10k installed"
            fi
        fi
    fi

    # Install useful plugins
    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    local plugins=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
        "fast-syntax-highlighting:https://github.com/zdharma-continuum/fast-syntax-highlighting"
    )

    for plugin_info in "${plugins[@]}"; do
        local plugin_name="${plugin_info%%:*}"
        local plugin_url="${plugin_info##*:}"
        local plugin_dir="$plugins_dir/$plugin_name"

        if [[ ! -d "$plugin_dir" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                print_dry_run "Would install plugin: $plugin_name"
            else
                print_info "Installing plugin: $plugin_name"
                if ! git clone "$plugin_url" "$plugin_dir" 2>&1; then
                    handle_warning "Failed to install plugin: $plugin_name" "Install it manually or check your internet connection"
                else
                    print_success "Plugin installed: $plugin_name"
                fi
            fi
        fi
    done
}

# Configure Fish shell
configure_fish() {
    print_info "Configuring Fish shell..."

    if ! command -v fish >/dev/null 2>&1; then
        print_error "Fish shell not found. Install it via Homebrew: brew install fish"
        return 1
    fi

    # Install Fisher plugin manager
    if [[ "$DRY_RUN" != "true" ]]; then
        fish -c "
            if not functions -q fisher
                curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
            end

            # Install useful plugins
            fisher install PatrickF1/fzf.fish
            fisher install franciscolourenco/done
            fisher install jorgebucaran/autopair.fish
        " 2>/dev/null || print_error "Failed to configure Fish plugins"
    else
        print_dry_run "Would configure Fish shell with plugins"
    fi
}

# Configure Bash (basic)
configure_bash() {
    print_info "Configuring Bash..."
    print_info "Basic Bash configuration (consider switching to Zsh for better experience)"
}

# Main shell configuration function
configure_shell() {
    print_info "Starting shell configuration..."

    # Create default configurations
    create_default_configs

    # Link configuration files
    link_configs

    # Configure shell-specific settings
    configure_shell_specifics

    print_success "Shell configuration completed!"

    # Suggest shell reload
    if [[ "$DRY_RUN" != "true" ]]; then
        print_info "💡 Tip: Run 'exec $SHELL' to reload your shell with new configurations"
    fi
}

# Run configuration if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_shell
fi