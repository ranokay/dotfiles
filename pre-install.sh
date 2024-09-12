#!/usr/bin/env bash

set -e -u -o pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_colored() {
  local color=$1
  local message=$2
  echo -e "${color}${message}${NC}"
}

# Function to print section headers
print_header() {
  local message=$1
  echo -e "\n${BLUE}==== $message ====${NC}"
}

# Function to prompt for confirmation
confirm() {
  if $AUTOCONFIRM; then
    return 0
  fi
  read -p "$1 (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
}

# Parse command-line arguments
DISK=""
AUTOCONFIRM=false

while [[ $# -gt 0 ]]; do
  case $1 in
  --disk)
    DISK="$2"
    shift 2
    ;;
  --auto-confirm)
    AUTOCONFIRM=true
    shift
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

if [ "$(uname)" == "Darwin" ]; then
  print_colored "$YELLOW" "macOS detected"
  confirm "This script will prepare the system for nix-darwin installation. Do you want to continue?"

  print_header "Installing Xcode"
  if [[ -e /Library/Developer/CommandLineTools/usr/bin/git ]]; then
    print_colored "$GREEN" "Xcode already installed."
  else
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
    softwareupdate -i "$PROD" --verbose
    print_colored "$GREEN" "Xcode installed successfully."
  fi

  print_header "Installing Rosetta"
  softwareupdate --install-rosetta --agree-to-license
  print_colored "$GREEN" "Rosetta installed successfully."

  print_header "Installing Nix"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

  print_colored "$GREEN" "All steps completed successfully. nix-darwin is now ready to be installed."
  echo -e "\nTo install nix-darwin configuration, run the following commands:"
  print_colored "$YELLOW" ". /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  print_colored "$YELLOW" "nix run nix-darwin -- switch --flake github:ranokay/dotfiles#mac1"

elif [ "$(uname)" == "Linux" ]; then
  print_colored "$YELLOW" "Linux detected"
  confirm "This script will prepare the system for NixOS installation. Do you want to continue?"

  if [ -z "$DISK" ]; then
    print_header "Available Disks"
    lsblk
    read -p "Enter the disk to partition (e.g., /dev/nvme0n1): " DISK
  fi

  print_header "Verifying Disk"
  confirm "Are you sure you want to format $DISK? This will erase all data on the disk."

  print_header "Partitioning Disk"
  if parted $DISK -- mklabel gpt &&
    parted $DISK -- mkpart ESP fat32 1MiB 512MiB &&
    parted $DISK -- set 1 boot on &&
    parted $DISK -- mkpart Nix 512MiB 100%; then
    print_colored "$GREEN" "Disk partitioned successfully."
  else
    print_colored "$RED" "Error partitioning disk."
    exit 1
  fi

  print_header "Creating Filesystems"
  if mkfs.fat -F32 -n boot ${DISK}p1 && mkfs.ext4 -F -L nix ${DISK}p2; then
    print_colored "$GREEN" "Filesystems created successfully."
  else
    print_colored "$RED" "Error creating filesystems."
    exit 1
  fi

  print_header "Retrieving UUIDs"
  BOOT_UUID=$(blkid -s UUID -o value ${DISK}p1)
  NIX_UUID=$(blkid -s UUID -o value ${DISK}p2)

  if [ -z "$BOOT_UUID" ] || [ -z "$NIX_UUID" ]; then
    print_colored "$RED" "Error retrieving UUIDs."
    exit 1
  fi

  print_header "Mounting Filesystems"
  if mount UUID=$NIX_UUID /mnt && mkdir -pv /mnt/boot && mount UUID=$BOOT_UUID /mnt/boot; then
    print_colored "$GREEN" "Filesystems mounted successfully."
  else
    print_colored "$RED" "Error mounting filesystems."
    exit 1
  fi

  print_colored "$GREEN" "All steps completed successfully. NixOS is now ready to be installed."
  echo -e "\nTo install NixOS configuration for your hostname, run the following command:"
  print_colored "$YELLOW" "sudo nixos-install --no-root-passwd --flake github:ranokay/dotfiles#hostname"
else
  print_colored "$RED" "Unsupported operating system."
  exit 1
fi
