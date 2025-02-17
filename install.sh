#!/usr/bin/env bash

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