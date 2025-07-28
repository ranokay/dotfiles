# Quick macOS Installation Guide

This guide will help you set up your complete Nix environment on a fresh macOS system in just a few commands.

## 🚀 One-Line Installation

### Full Installation (Recommended)

For a completely automated setup with all features, run:

```bash
curl -fsSL https://raw.githubusercontent.com/ranokay/dotfiles/main/install.sh | bash
```

### Quick Bootstrap (Minimal)

For a minimal setup that gets you started quickly:

```bash
curl -fsSL https://raw.githubusercontent.com/ranokay/dotfiles/main/bootstrap.sh | bash
```

**Difference:**

- **`install.sh`**: Full-featured installer with Git setup, error handling, and comprehensive configuration
- **`bootstrap.sh`**: Minimal 4-step script that gets you running quickly with basic setup

## 📋 Manual Installation

If you prefer to download and inspect the script first:

```bash
# Download the installer
curl -fsSL https://raw.githubusercontent.com/ranokay/dotfiles/main/install.sh -o install.sh

# Make it executable
chmod +x install.sh

# Review the script (recommended)
cat install.sh

# Run the installer
./install.sh
```

## 🔧 Installation Options

The installer supports several options:

```bash
# Show help information
./install.sh --help

# Dry run (show what would be done)
./install.sh --dry-run

# Normal installation
./install.sh
```

## 📦 What Gets Installed

The installation script will:

1. **✅ Install Determinate Nix** - Enhanced Nix with better performance
2. **✅ Setup Git Configuration** - Configure your Git username and email
3. **✅ Clone Dotfiles** - Download your Nix configuration
4. **✅ Install Dependencies** - Essential tools like `just`, `alejandra`, `nil`
5. **✅ Configure Shell** - Set up your shell environment for Nix
6. **✅ Apply Configuration** - Build and switch to your Nix configuration

## 🎯 Prerequisites

The only requirement is a fresh macOS system. The script will:

- Check for macOS compatibility
- Install Xcode Command Line Tools (if needed)
- Handle all other dependencies automatically

## 🔄 Customization

Before running the installer, you may want to customize:

1. **Repository URL**: Edit the `REPO_URL` variable in `install.sh` to point to your fork
2. **Directory Location**: Change `DOTFILES_DIR` if you prefer a different location
3. **Dependencies**: Modify the `install_dependencies()` function to add/remove tools

## 🛠️ Post-Installation

After successful installation, you'll have access to:

### Essential Commands

```bash
# Navigate to your nix configuration
cd ~/dotfiles/nix

# View all available commands
just --list

# Apply configuration changes
just rebuild

# Update system packages
just up

# Clean up old generations
just gc
```

### Directory Structure

```
~/dotfiles/nix/
├── flake.nix              # Main configuration
├── Justfile               # Task runner commands
├── hosts/mbp/             # Your machine-specific config
├── profiles/              # Reusable system profiles
└── home/profiles/         # User environment profiles
```

## 🚨 Troubleshooting

### Common Issues

**Script fails with permission errors:**

- Don't run as root: `./install.sh` (not `sudo ./install.sh`)
- Ensure you have admin privileges for `sudo` commands

**Git clone fails:**

- The script tries SSH first, then HTTPS
- Make sure your GitHub SSH keys are set up or use HTTPS URL

**Build fails:**

- Check your internet connection
- Run `just check` to validate configuration
- Check flake.lock for any issues

**Nix command not found after installation:**

- Restart your terminal or run: `source ~/.zshrc`
- Verify Nix installation: `which nix`

### Getting Help

1. **Check logs**: The script provides detailed output for each step
2. **Re-run installation**: The script is idempotent and can be safely re-run
3. **Manual steps**: You can perform any step manually if needed
4. **Documentation**: See `nix/README.md` for detailed usage instructions

## 🔐 Security Notes

- The script uses the official Determinate Systems installer
- All packages come from trusted Nix repositories
- Configuration is version-controlled and auditable
- No sensitive data is stored in the configuration

## 📞 Support

If you encounter issues:

1. Check the error output carefully
2. Verify prerequisites are met
3. Try running individual commands manually
4. Check the GitHub repository for updates

## 🎉 Next Steps

Once installation is complete:

1. **Explore the configuration**: Browse the `nix/` directory structure
2. **Customize settings**: Edit profiles to match your preferences
3. **Add applications**: Modify Homebrew casks or Nix packages
4. **Create new hosts**: Use `just new-host` for additional machines
5. **Share improvements**: Contribute back to the configuration

Happy Nix-ing! 🚀
