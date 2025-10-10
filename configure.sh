#!/usr/bin/env bash

# ⚠️  DEPRECATED: This script is maintained for backward compatibility only.
# Please use './setup.sh macos-*' instead for configuration-only setup.
# Run './setup.sh --help' to see available options.

echo "⚠️  WARNING: configure.sh is deprecated. Please use ./setup.sh instead."
echo "Continuing with legacy configuration in 5 seconds (Ctrl+C to cancel)..."
sleep 5

source "./scripts/utils.sh"

# Perform initial checks
source "./scripts/checks.sh"
check_system

# Apply system configurations
source "./scripts/macos.sh"
apply_macos_configuration

print_success "System configuration completed!" 