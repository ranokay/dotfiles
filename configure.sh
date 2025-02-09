#!/usr/bin/env bash

source "./scripts/utils.sh"

# Perform initial checks
source "./scripts/checks.sh"
check_system

# Apply system configurations
source "./scripts/macos.sh"
apply_macos_configuration

print_success "System configuration completed!" 