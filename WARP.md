# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is a macOS-focused dotfiles repository that automates the setup and configuration of a new Mac development environment. The repository uses a modular script architecture with clear separation of concerns.

## Core Architecture

### Script Organization

The repository follows a modular design with scripts organized by functionality:

```
scripts/
├── utils.sh        # Shared utilities (colors, confirmation prompts, command checks)
├── checks.sh       # System validation (macOS version, Xcode CLI tools)
├── apps.sh         # Application installation orchestration
├── brew.sh         # Homebrew and package management
├── git.sh          # Git configuration with 1Password SSH signing
└── macos.sh        # Comprehensive macOS system preferences
```

### Entry Points

- **`install.sh`** - Full initial setup (system checks → apps → macOS config)
- **`configure.sh`** - System configuration only (skips app installation)

### Configuration Management

- **Brewfile** (Ruby DSL format) - Centralized package management for:
  - Homebrew casks (GUI applications)
  - CLI tools via brew
  - Mac App Store apps via `mas`
- **Git Configuration** - Automated setup with 1Password SSH commit signing
- **macOS Defaults** - Extensive system preference automation

## Common Development Commands

### Enhanced Setup (Recommended)
```bash
# Full setup with all modules (equivalent to ./install.sh)
./setup.sh

# Configuration only - applies macOS settings without installing apps
./setup.sh macos-*

# Dry-run to preview changes without applying them
./setup.sh --dry-run

# Install only packages and configure Git
./setup.sh brew git

# Configure shell and development environment
./setup.sh shell git macos-general

# List available configuration modules
./setup.sh --list

# Verbose output with detailed logging
./setup.sh --verbose
```

### Legacy Setup (Maintained for Compatibility)
```bash
# Full setup - installs apps and configures system
./install.sh

# Configuration only - applies macOS settings without installing apps
./configure.sh
```

### Package Management
```bash
# Update package definitions and sync installed packages
brew bundle --file=config/Brewfile

# Check what packages would be removed
brew bundle cleanup --file=config/Brewfile

# Remove packages not in Brewfile (interactive)
brew bundle cleanup --force --file=config/Brewfile

# Install single package and update Brewfile
brew install <package> && brew bundle dump --file=config/Brewfile --force
```

### Individual Component Configuration
```bash
# Run specific configuration modules
source ./scripts/utils.sh
source ./scripts/git.sh && configure_git
source ./scripts/macos.sh && configure_dock  # or other configure_* functions

# Configure shell environment
./scripts/shell.sh  # Setup shell configurations and dotfile linking
```

### Backup and Restore
```bash
# Create backup of current settings before making changes
./scripts/backup.sh backup

# List available backups
./scripts/backup.sh list

# Restore settings from a specific backup
./scripts/backup.sh restore 20231010_143022

# Preview what would be restored (dry-run)
DRY_RUN=true ./scripts/backup.sh restore 20231010_143022
```

### Testing and Validation
```bash
# Validate system requirements
source ./scripts/checks.sh && check_system

# Check git configuration
git config --global --list | grep -E "(user|gpg|commit)"

# Verify Homebrew packages
brew list --cask
brew list --formula
mas list

# Check specific macOS defaults (using helper functions)
source ./scripts/utils.sh && source ./scripts/macos.sh
# Check if a setting matches expected value
check_default "NSGlobalDomain" "KeyRepeat" "2" "int" && echo "Key repeat is optimized" || echo "Key repeat needs adjustment"
# Check system configuration
check_system_config "ComputerName" "mbp" && echo "Computer name is set" || echo "Computer name needs update"
```

## Key Design Patterns

### Error Handling and UX
- Color-coded output with `print_success`, `print_error`, `print_info`, `print_dry_run`
- Interactive confirmations for destructive operations
- Comprehensive error checking with early exits
- Timestamped logging to `~/.dotfiles-setup.log`
- Progress indicators and execution duration tracking
- Automatic rollback system for failed operations
- Pre-execution backup creation with restore capability

### Modular Configuration
- Each macOS configuration area is isolated in separate functions
- Git configuration checks existing values before updating
- Homebrew operations handle cleanup and installation separately
- macOS defaults use helper functions (`check_default`, `set_default`) to avoid unnecessary writes
- System-level configuration (`scutil`) has dedicated helpers for consistent checking
- Selective module execution with argument parsing and glob pattern support
- Dry-run mode for all configuration changes with preview capabilities
- Brewfile validation with syntax checking and package availability verification
- Automated shell configuration with Oh My Zsh, plugins, and dotfile linking
- Homebrew service management and package upgrade checking
- Cross-shell compatibility (zsh, fish, bash) with intelligent detection

### System Integration
- 1Password SSH signing integration with macOS/Linux path detection
- Hot corner assignments for productivity workflows
- Comprehensive Finder, Dock, and input device customization
- Smart defaults checking - only applies changes when current values differ from desired values

### Package Management Strategy
The Brewfile uses Ruby syntax with arrays for organization:
- Packages grouped by category (Development, Security, Media, etc.)
- Mac App Store apps include both name and ID for reliability
- Separation between CLI tools and GUI applications

## Environment Assumptions

- **Target OS**: macOS 12.0+ (Monterey and later)
- **Dependencies**: Xcode Command Line Tools (auto-installed)
- **Authentication**: 1Password for SSH commit signing
- **Package Manager**: Homebrew with bundle support
- **Shell**: Bash for scripts (zsh/fish supported via Brewfile)

## Notable Configurations

### Security & Privacy
- 1Password integration for Git commit signing
- SSH key configured: `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOlQ9WC58WUVNYtM0tL1YJHDtCMpnLBhtZ3UcQH3dwj`
- Git user: `ranokay <github@ranokay.com>`

### Development Environment
- Modern CLI tools (bat, eza, gh, fnm)
- Multiple editors (VS Code, Cursor, Zed)
- Container runtime (OrbStack)
- Development tools (Postman, Warp terminal)

### System Optimizations
- Aggressive performance tuning (reduced animations, fast key repeat)
- Developer-friendly defaults (show hidden files, disable autocorrect)
- Productivity shortcuts (hot corners, Dock autohide)
- Computer name set to "mbp"