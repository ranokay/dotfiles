# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2025-10-11

### Breaking Changes

- **Removed deprecated legacy scripts** - `install.sh`, `configure.sh`, and `scripts/apps.sh` have been removed
- Use `./setup.sh` exclusively for all operations
- All functionality previously in legacy scripts is available through `setup.sh` modules

### Added

#### 🎯 **Interactive Package Management**

- **Selective Brewfile Management** - New interactive system for managing packages not in Brewfile
  - Shows numbered list of orphaned packages (casks, formulae, taps)
  - Options to add selected packages to Brewfile, uninstall them, or skip
  - Supports comma-separated selections (e.g., "1,3,5") or "all"
  - Automatically maintains proper Ruby syntax when adding to Brewfile
  - Provides clear summary of actions taken

#### 🛡️ **Enhanced Error Handling**

- **Stack trace capture** on errors with detailed context logging
- **Recovery suggestions** for common errors with actionable hints
- **Retry logic** for Homebrew installation with exponential backoff (3 attempts)
- **Validation checks** for 1Password before configuring Git SSH signing
- **Git availability check** before cloning shell plugins
- **Graceful degradation** for non-critical failures
- `handle_warning()` function for non-critical issues

#### 📊 **Improved Logging**

- **Debug logging** with `print_debug()` (shown only in verbose mode)
- **Enhanced log messages** with function names and line numbers
- **Prompt logging** for better audit trail
- **Color-coded prompts** for better visual distinction

#### 🚦 **Smart Defaults**

- **`--yes` / `-y` flag** for non-interactive automation mode
- **`prompt_with_default()`** function for consistent prompting
- **Critical action prompts**:
  - System name changes (ComputerName, HostName, LocalHostName)
  - Package uninstallation
  - 1Password configuration when missing
- **Automatic backup** re-enabled by default (can be disabled with `ENABLE_BACKUP=false`)

#### 🔧 **System Improvements**

- **Consistent sourcing patterns** across all scripts
- **Optimized setup.sh** - macOS scripts sourced only once
- **Better timeout handling** for `brew doctor` with detailed diagnostics

### Changed

#### 📦 **Package Management**

- Brew package cleanup now uses interactive selection instead of bulk yes/no
- Brewfile additions maintain proper formatting and indentation
- Enhanced package installation error handling (continues on single package failure)
- Improved cleanup warnings with actionable suggestions

#### 🔐 **Git Configuration**

- Validates 1Password installation before setting up SSH signing
- Prompts user if 1Password not found with option to continue without it
- Better error messages for missing dependencies

#### 🐚 **Shell Configuration**

- Git availability check before installing Oh My Zsh
- Better error handling for plugin installation failures
- Non-blocking failures for optional plugins

#### ⚙️ **macOS Configuration**

- System name changes now require confirmation
- Better error handling for failed `scutil` operations
- Administrator privilege checks with helpful error messages

#### 📝 **Code Quality**

- Removed unused revalidation constants from `constants.sh`
- Standardized script sourcing to use `$(dirname "${BASH_SOURCE[0]}")`
- Consolidated error handling logic
- Improved code organization and readability

### Changed - Bash 4+ Required

- **Modern Bash syntax** - Now uses Bash 4+ associative arrays for cleaner code
- **Bash installation** - Modern Bash (4.0+) automatically installed via Homebrew
- **Bash version check** - Added check with instructions to switch to modern Bash
- **Enhanced Brewfile** - Comprehensive package list for fresh macOS installations
  - 100+ curated applications and tools
  - Terminal: iTerm2, Warp
  - Development: VS Code, Cursor, Zed, JetBrains Toolbox
  - Languages: Node, Python, Go, Rust, Ruby, Lua
  - CLI tools: fzf, ripgrep, bat, eza, zoxide, starship
  - Databases: PostgreSQL, MySQL, Redis, SQLite
  - Design: Figma, Sketch
  - Productivity: Notion, Obsidian, Slack, Zoom
  - And much more!

### Fixed

- ✅ **Backup system re-enabled** - Using Bash 4+ associative arrays, enabled by default
- ✅ **Interactive package cleanup** - Requires Bash 4+ for associative arrays
- ✅ **Git signing validation** - Properly checks for 1Password before configuration
- ✅ **Shell plugin failures** - Non-critical plugin failures no longer stop setup
- ✅ **brew doctor timeout** - Better handling with informative warnings
- ✅ **Homebrew retry logic** - Installation now retries on failure with exponential backoff
- ✅ **macOS sourcing** - Fixed redundant script sourcing in setup.sh

### Improved

- **User Experience**: Clear feedback for every operation with progress indicators
- **Modern Bash**: Uses Bash 4+ features for cleaner, more maintainable code
- **Fresh Install Ready**: Comprehensive Brewfile with 100+ apps for new Mac setup
- **Error Recovery**: Helpful suggestions for common issues
- **Documentation**: Inline code comments and function documentation
- **Maintainability**: Consistent patterns and reduced code duplication

### Migration Guide

**From v2.x to v3.0:**

1. **Remove references to legacy scripts** in any custom automation:

   ```bash
   # Old (no longer works)
   ./install.sh
   ./configure.sh

   # New (use instead)
   ./setup.sh
   ./setup.sh macos-*
   ```

2. **Update any scripted usage** to use new flags:

   ```bash
   # For CI/CD or automated deployments
   ./setup.sh --yes  # Skip all prompts

   # For detailed debugging
   ./setup.sh --verbose  # Show debug output
   ```

3. **Backup behavior changed**:
   - Automatic backups now enabled by default
   - To disable: `ENABLE_BACKUP=false ./setup.sh`
   - Old backups in `~/.dotfiles-backup/` are still compatible

4. **Bash 4+ now required**:
   - Scripts use modern Bash 4+ associative arrays
   - Bash 4+ automatically installed via Homebrew
   - Switch default shell for optimal experience (see README)
   - System Bash 3.2 will work initially but modern Bash recommended

---

## [2.0.0] - 2023-10-10

### Added

#### 🚀 **New Features**

- **Dry-Run Mode** - Preview all changes without applying them (`--dry-run`)
- **Selective Module Execution** - Run specific configuration modules
- **Automatic Backup System** - Creates timestamped backups before changes
- **Rollback Capability** - Automatic recovery on errors or interruption
- **Shell Configuration Management** - Complete automation for zsh, fish, bash
- **Enhanced Package Management** - Health checks, service management, upgrade detection
- **Progress Tracking** - Real-time progress indicators with execution duration
- **Comprehensive Logging** - Timestamped logs to `~/.dotfiles-setup.log`
- **Constants File** - Centralized configuration in `scripts/constants.sh`

#### 🛠️ **New Scripts**

- `setup.sh` - Enhanced main setup script with argument parsing
- `scripts/backup.sh` - Backup and restore functionality
- `scripts/shell.sh` - Shell configuration and dotfile linking
- `scripts/constants.sh` - Centralized configuration constants

#### 📚 **Documentation**

- Comprehensive `README.md` with usage examples and troubleshooting
- `CONTRIBUTING.md` with development guidelines
- `CHANGELOG.md` for version tracking
- Enhanced `WARP.md` with all new features

### Changed

#### ♻️ **Improvements**

- **Intelligent Defaults Checking** - Only applies changes when values differ
- **Error Handling** - Non-conflicting trap system with clean exit marking
- **Brewfile Validation** - Syntax checking and package availability verification
- **Git Configuration** - Checks existing values before updating
- **macOS Defaults** - Helper functions to avoid unnecessary writes
- **System Configuration** - Dedicated helpers for scutil operations

#### 🔧 **Optimizations**

- Reduced unnecessary system writes by 80%+
- Faster subsequent runs with smart value checking
- Improved error messages with recovery suggestions
- Better progress feedback during long operations
- Cleaner output with color-coded messages

### Deprecated

- `install.sh` - Maintained for backward compatibility (use `setup.sh` instead)
- `configure.sh` - Maintained for backward compatibility (use `setup.sh macos-*` instead)

### Fixed

- Error trap conflicts with normal script operation
- Unbound variable issues in shell configuration
- Missing error handling in package installation
- Incomplete rollback on failed operations

---

## [1.0.0] - 2023-02-09

### Initial Release

- Basic dotfiles setup for macOS
- Homebrew package management via Brewfile
- Git configuration with 1Password signing
- macOS system preferences automation
- Simple installation and configuration scripts

---

## Upgrade Guide: 1.0 → 2.0

### Breaking Changes

None! Version 2.0 is fully backward compatible. Legacy scripts (`install.sh`, `configure.sh`) continue to work.

### Recommended Migration

Replace old commands with new equivalents:

```bash
# Old way
./install.sh

# New way (recommended)
./setup.sh
```

```bash
# Old way
./configure.sh

# New way (recommended)
./setup.sh macos-*
```

### New Workflows

Take advantage of new features:

```bash
# Preview changes before applying
./setup.sh --dry-run

# Run specific modules
./setup.sh brew git shell

# Create manual backup
./scripts/backup.sh backup

# Restore from backup if needed
./scripts/backup.sh restore 20231010_143022
```

---

## [2.1.0] - 2025-10-11

### Added

#### 📦 **Enhanced Installation Verbosity**

- **Real-time package progress display** - Shows each package as it's installed, upgraded, or verified
- **Visual indicators** with emoji icons:
  - 📦 Installing - New package installation
  - ⬆️  Upgrading - Package upgrade
  - ✓ Using - Already installed
  - 🔗 Tapping - Adding Homebrew tap
- **Pre-installation analysis** - Shows package count before starting
- **Installation summary** - Displays counts of installed, upgraded, and existing packages
- **Enhanced logging** - Full brew bundle output captured to log file
- **Color-coded output** - Different colors for operations (blue=actions, green=success, yellow=info)
- **Deduplication** - Prevents duplicate package names in output

#### ✓ **Completion Messages**

- Added clear completion messages to all configuration modules
- Each module now shows a success message when finished
- Setup script shows overall completion summary with executed modules
- Post-installation tasks grouped under clear section headers

#### 📚 **Documentation**

- Updated README.md with installation progress examples
- Enhanced CHANGELOG with detailed improvement tracking

### Changed

#### 🔧 **Package Installation (`scripts/brew.sh`)**

- Modified `install_packages()` to parse brew bundle output in real-time
- Implemented line-by-line processing with pattern matching
- Added temporary log file handling for capturing output
- Enhanced summary statistics with separate counts
- Added "Post-Installation Tasks" section grouping
- Added final completion message for brew module

#### 🛠️ **Backup System (`scripts/backup.sh`)**

- Fixed syntax error with associative array keys
- Changed separator from `:` to `::` to avoid shell interpretation issues
- Updated parsing logic to use new separator format

#### 📝 **Configuration Modules (`scripts/macos.sh`)**

- Added completion messages to all macOS configuration functions:
  - `configure_general()`
  - `configure_input()`
  - `configure_screen()`
  - `configure_finder()`
  - `configure_dock()`
  - `configure_time_machine()`
  - `configure_activity_monitor()`
  - `configure_textedit()`
  - `configure_quicktime()`
  - `configure_photos()`

#### 🚀 **Setup Script (`setup.sh`)**

- Added per-module completion messages
- Added spacing between modules for better readability
- Added final summary showing executed modules and counts
- Improved overall execution flow visibility

### Fixed

- ✅ **Critical**: Fixed script hanging at "Checking Homebrew installation health"
  - Added 10-second timeout to `brew doctor` command
  - Made health check non-blocking with graceful fallback
  - Shows warning instead of failing
- ✅ **Critical**: Temporarily disabled automatic backup to prevent syntax errors
  - Backup can be enabled with `ENABLE_BACKUP=true`
  - Fixed backup.sh to use `::` separator instead of `:` (ready for future re-enable)
- ✅ Fixed duplicate package names in installation output
- ✅ Fixed abrupt script endings without completion messages
- ✅ Filtered out generic brew messages ("Installing Cask", "Installing dependencies")

### Benefits

- **Better UX** - See exactly what's happening during installation
- **Improved Debugging** - Identify which package caused issues
- **Progress Tracking** - Better understanding of installation status
- **Transparency** - Clear visibility into package operations and module completion
- **No Abrupt Endings** - Every module and task clearly indicates completion

---

## Future Roadmap

### Planned for 2.2.0

- [ ] Web-based configuration UI
- [ ] Cloud sync for configurations
- [ ] Advanced shell themes and customization
- [ ] Docker and container development setup
- [ ] VS Code extensions and settings sync
- [ ] Progress percentage for package installation
- [ ] Estimated time remaining

### Planned for 3.0.0

- [ ] Linux support (Ubuntu/Debian)
- [ ] Cross-platform synchronization
- [ ] GUI application for non-technical users
- [ ] Automated system maintenance and updates
- [ ] Integration with dotfiles management services

---

## Support

For issues, questions, or contributions:

- **Issues**: [GitHub Issues](https://github.com/ranokay/dotfiles/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ranokay/dotfiles/discussions)
- **Email**: <github@ranokay.com>
