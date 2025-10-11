#!/usr/bin/env bash

# Constants for dotfiles setup
# This file contains all configuration constants used across the dotfiles scripts

# Version
readonly DOTFILES_VERSION="3.0.0"

# Paths
readonly DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
readonly SCRIPTS_DIR="${DOTFILES_DIR}/scripts"
readonly CONFIG_DIR="${DOTFILES_DIR}/config"
readonly BACKUP_DIR="${HOME}/.dotfiles-backup"
readonly LOG_FILE="${LOG_FILE:-${HOME}/.dotfiles-setup.log}"

# macOS Requirements
readonly MIN_MACOS_VERSION="12.0.0"

# Backup Settings
readonly MAX_BACKUPS=5
readonly BACKUP_TIMESTAMP_FORMAT="%Y%m%d_%H%M%S"

# Homebrew Settings
readonly HOMEBREW_BREWFILE="${CONFIG_DIR}/Brewfile"
readonly HOMEBREW_CLEANUP_DAYS=30

# Git Configuration
readonly GIT_USER_NAME="ranokay"
readonly GIT_USER_EMAIL="github@ranokay.com"
readonly GIT_SIGNING_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOlQ9WC58WUVNYtM0tL1YJHDtCMpnLBhtZ3UcQH3dwj"

# macOS System Configuration
readonly SYSTEM_NAME="mbp"

# Shell Configurations
readonly OH_MY_ZSH_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
readonly P10K_REPO="https://github.com/romkatv/powerlevel10k.git"
readonly FISHER_URL="https://git.io/fisher"

# Essential Homebrew Services
readonly ESSENTIAL_SERVICES=("tailscale")

# Module Names (for setup.sh)
readonly MODULES=(
    "checks"
    "brew"
    "git"
    "shell"
    "macos-general"
    "macos-input"
    "macos-screen"
    "macos-finder"
    "macos-dock"
    "macos-apps"
)

# Export all constants
export DOTFILES_VERSION
export DOTFILES_DIR SCRIPTS_DIR CONFIG_DIR BACKUP_DIR LOG_FILE
export MIN_MACOS_VERSION
export MAX_BACKUPS BACKUP_TIMESTAMP_FORMAT
export HOMEBREW_BREWFILE HOMEBREW_CLEANUP_DAYS
export GIT_USER_NAME GIT_USER_EMAIL GIT_SIGNING_KEY
export SYSTEM_NAME
export OH_MY_ZSH_URL P10K_REPO FISHER_URL