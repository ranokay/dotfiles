#!/usr/bin/env bash

# Minimal Bootstrap Script for macOS Nix Configuration
# This is a lightweight version that gets you started quickly

set -euo pipefail

echo "🚀 Bootstrapping macOS Nix Environment..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

echo -e "${BLUE}Step 1/4:${NC} Installing Determinate Nix..."
if ! command -v nix &> /dev/null; then
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
    echo -e "${GREEN}✅ Nix installed${NC}"
else
    echo -e "${YELLOW}⚠️  Nix already installed${NC}"
fi

# Source nix environment
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo -e "${BLUE}Step 2/4:${NC} Installing Just task runner..."
if ! command -v just &> /dev/null; then
    nix profile install nixpkgs#just
    echo -e "${GREEN}✅ Just installed${NC}"
else
    echo -e "${YELLOW}⚠️  Just already installed${NC}"
fi

echo -e "${BLUE}Step 3/4:${NC} Cloning dotfiles..."
DOTFILES_DIR="$HOME/dotfiles"
# 🔧 Update these URLs to point to your dotfiles repository
REPO_SSH="git@github.com:ranokay/dotfiles.git"  # ← Change this to your repo!
REPO_HTTPS="https://github.com/ranokay/dotfiles.git"  # ← Change this to your repo!

if [[ ! -d "$DOTFILES_DIR" ]]; then
    # Try SSH first, fallback to HTTPS
    if ! git clone "$REPO_SSH" "$DOTFILES_DIR" 2>/dev/null; then
        git clone "$REPO_HTTPS" "$DOTFILES_DIR"
    fi
    echo -e "${GREEN}✅ Dotfiles cloned${NC}"
else
    echo -e "${YELLOW}⚠️  Dotfiles directory already exists${NC}"
fi

echo -e "${BLUE}Step 4/4:${NC} Building configuration..."
cd "$DOTFILES_DIR/nix"
just rebuild

echo ""
echo -e "${GREEN}🎉 Bootstrap complete!${NC}"
echo ""
echo "Next steps:"
echo "  • Restart your terminal: source ~/.zshrc"
echo "  • View commands: cd ~/dotfiles/nix && just --list"
echo "  • Customize: Edit files in ~/dotfiles/nix/"
echo ""
echo "📖 Full documentation: ~/dotfiles/nix/README.md"