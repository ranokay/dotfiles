#!/usr/bin/env bash

# ⚠️  DEPRECATED: This script is maintained for backward compatibility only.
# Please use ./setup.sh instead for enhanced features and better UX.
# Run './setup.sh --help' to see available options.

echo "⚠️  WARNING: install.sh is deprecated. Please use ./setup.sh instead."
echo "Continuing with legacy installation in 5 seconds (Ctrl+C to cancel)..."
sleep 5

# Source utility functions
source "./scripts/utils.sh"

# Perform initial checks
source "./scripts/checks.sh"
check_system
check_xcode

# Install applications and configure Git
source "./scripts/apps.sh"
install_applications

# Apply system configurations
source "./scripts/macos.sh"
apply_macos_configuration

print_success "Initial setup completed successfully!"