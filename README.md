# 🚀 Dotfiles - macOS Development Environment Setup

> **Version 2.0** - Enterprise-grade dotfiles management with automated backup, rollback, and modular configuration.

A comprehensive, production-ready dotfiles repository for automating macOS development environment setup. Features include intelligent defaults checking, dry-run mode, automatic backups, rollback capabilities, and shell configuration management.

[![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue.svg)](https://www.apple.com/macos/)
[![Shell](https://img.shields.io/badge/shell-bash%2Fzsh%2Ffish-green.svg)](https://www.gnu.org/software/bash/)

---

## ✨ Features

### 🔄 **Smart Configuration Management**

- **Intelligent Defaults Checking** - Only applies changes when values differ from desired state
- **Dry-Run Mode** - Preview all changes before applying them
- **Selective Module Execution** - Run only specific configuration modules
- **Progress Tracking** - Real-time progress indicators and execution duration

### 🛡️ **Safety & Recovery**

- **Automatic Backups** - Creates timestamped backups before making changes
- **Rollback System** - Automatic recovery on errors or script interruption
- **Change Tracking** - Maintains rollback stack for all modifications
- **Backup Management** - Automatically keeps 5 most recent backups

### 📦 **Package Management**

- **Brewfile Integration** - Centralized package management with validation
- **Real-Time Progress** - Verbose output showing each package as it installs
- **Health Monitoring** - Automatic health checks with `brew doctor`
- **Service Management** - Manages essential Homebrew services
- **Upgrade Detection** - Interactive prompts for outdated packages

### 🐚 **Shell Configuration**

- **Multi-Shell Support** - Zsh, Fish, and Bash with intelligent detection
- **Oh My Zsh Automation** - Automatic installation with Powerlevel10k theme
- **Plugin Management** - Pre-configured useful plugins and enhancements
- **Dotfile Linking** - Symlink management with backup and restore

---

## 🚀 Quick Start

### Prerequisites

- **macOS 12.0+** (Monterey or later)
- **Terminal** with internet connection
- **Administrator access** for system configuration

### Installation

```bash
# Clone and run setup
git clone https://github.com/ranokay/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

### First Steps After Setup

```bash
# Reload your shell
exec $SHELL

# Verify installation
brew list
git config --list | grep user
```

---

## 📖 Usage Guide

### Basic Commands

```bash
# Full setup with all modules
./setup.sh

# Preview changes (dry-run)
./setup.sh --dry-run

# Show available modules
./setup.sh --list

# Get help
./setup.sh --help
```

### Module-Based Setup

```bash
# Install packages and configure Git
./setup.sh brew git

# Configure shell environment
./setup.sh shell

# Configure all macOS settings
./setup.sh macos-*

# Configure only Dock and Finder
./setup.sh macos-dock macos-finder
```

### Advanced Usage

```bash
# Verbose logging
./setup.sh --verbose

# Skip system checks
./setup.sh --skip-checks brew

# Custom log file
./setup.sh --log-file ~/my-setup.log
```

---

## 🔧 Configuration Modules

| Module | Description |
|--------|-------------|
| `checks` | System validation (macOS version, Xcode CLI) |
| `brew` | Homebrew and package management |
| `git` | Git configuration with 1Password signing |
| `shell` | Shell setup (zsh, fish, Oh My Zsh) |
| `macos-general` | General UI/UX settings |
| `macos-input` | Input device configuration |
| `macos-screen` | Screen and screenshot settings |
| `macos-finder` | Finder customization |
| `macos-dock` | Dock and hot corner setup |
| `macos-apps` | Application-specific settings |

---

## 💾 Backup & Restore

### Automatic Backups

Backups are automatically created before any changes:

```bash
# Backups are stored in ~/.dotfiles-backup/
ls -la ~/.dotfiles-backup/
```

### Manual Backup Operations

```bash
# Create manual backup
./scripts/backup.sh backup

# List available backups
./scripts/backup.sh list

# Restore from backup
./scripts/backup.sh restore 20231010_143022

# Dry-run restore
DRY_RUN=true ./scripts/backup.sh restore 20231010_143022
```

---

## 📦 Package Management

### Installation Progress

During installation, you'll see real-time progress for each package:

```bash
▶ Package Installation Phase
  ↳ Analyzing package requirements...
→ Found 15 package(s) to install/update

  📦 Installing node
  ⬆️  Upgrading git
  ✓ Using docker
  ...

  ↳ Summary:
✓   Installed: 8 package(s)
✓   Upgraded: 2 package(s)
→   Already installed: 5 package(s)
```

### Managing Packages

```bash
# Sync packages with Brewfile
brew bundle --file=config/Brewfile

# Check outdated packages
brew outdated

# Add new package
brew install package-name
brew bundle dump --file=config/Brewfile --force
```

### Brewfile Format

Edit `config/Brewfile` to add packages:

```ruby
casks << 'visual-studio-code'
brews << 'node'
mas << { name: 'Xcode', id: 497799835 }
```

---

## 🐚 Shell Configuration

### Zsh (Recommended)

Automatically installs:

- Oh My Zsh framework
- Powerlevel10k theme
- Useful plugins (autosuggestions, syntax highlighting)

### Fish Shell

Automatically installs:

- Fisher plugin manager
- Useful plugins (fzf, done, autopair)

### Configuration Files

Located in `config/shell/`:

- `zshrc` - Zsh configuration
- `zsh_aliases` - Custom aliases
- `config.fish` - Fish configuration

---

## 🔍 Troubleshooting

### Common Issues

**Homebrew fails to install:**

```bash
# Install manually first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
./setup.sh --skip-checks brew
```

**Permission errors:**

```bash
chmod +x setup.sh scripts/*.sh
./setup.sh
```

**Script fails midway:**

```bash
# Check logs
tail -f ~/.dotfiles-setup.log

# Restore from backup
./scripts/backup.sh list
./scripts/backup.sh restore <timestamp>
```

### Getting Help

- View logs: `cat ~/.dotfiles-setup.log`
- Test module: `./setup.sh --dry-run <module>`
- Verbose mode: `./setup.sh --verbose`

---

## 🗂️ Repository Structure

```
dotfiles/
├── setup.sh           # Main setup script
├── scripts/           # Core functionality
│   ├── constants.sh   # Configuration constants
│   ├── utils.sh       # Shared utilities
│   ├── checks.sh      # System validation
│   ├── brew.sh        # Package management
│   ├── git.sh         # Git configuration
│   ├── shell.sh       # Shell setup
│   ├── macos.sh       # macOS preferences
│   └── backup.sh      # Backup/restore
├── config/            # Configuration files
│   └── Brewfile       # Package definitions
└── README.md          # Documentation
```

---

## 🛠️ Development

### Testing

```bash
# Syntax check
bash -n setup.sh scripts/*.sh

# Dry-run test
./setup.sh --dry-run

# Module test
./setup.sh --dry-run shell
```

### Adding Modules

1. Create script in `scripts/`
2. Add to `scripts/constants.sh`
3. Add case in `setup.sh`
4. Update documentation

---

## 🤝 Contributing

Contributions welcome! Please:

1. Test with dry-run mode
2. Maintain backward compatibility
3. Update documentation
4. Follow existing code style

---

## 📄 License

MIT License - Open source and free to use.

---
