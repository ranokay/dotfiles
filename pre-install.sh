#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status, treat unset variables as an error, and consider failures in pipes.
set -e -u -o pipefail

# ANSI color codes for colored output
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

# Function to print section headers in blue
print_header() {
  local message=$1
  echo -e "\n${BLUE}==== $message ====${NC}"
}

# Function to prompt the user for confirmation, bypassed if --auto-confirm is set
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

# Parse command-line arguments for disk and auto-confirmation
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

# macOS setup for nix-darwin
if [ "$(uname)" == "Darwin" ]; then
  print_colored "$YELLOW" "macOS detected"
  confirm "This script will prepare the system for nix-darwin installation. Do you want to continue?"

  print_header "Checking for required tools (Xcode and Rosetta)"
  # Check if Xcode is installed
  if [[ -e /Library/Developer/CommandLineTools/usr/bin/git ]]; then
    print_colored "$GREEN" "Xcode already installed."
  else
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
    softwareupdate -i "$PROD" --verbose
    print_colored "$GREEN" "Xcode installed successfully."
  fi

  # Install Rosetta
  print_header "Installing Rosetta"
  softwareupdate --install-rosetta --agree-to-license
  print_colored "$GREEN" "Rosetta installed successfully."

  # Install Nix package manager
  print_header "Installing Nix"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

  print_colored "$GREEN" "All steps completed successfully. nix-darwin is now ready to be installed."
  echo -e "\nTo install nix-darwin configuration, run the following commands:"
  print_colored "$YELLOW" ". /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  print_colored "$YELLOW" "nix run nix-darwin -- switch --flake github:ranokay/dotfiles#mac1"

# Linux setup for NixOS
elif [ "$(uname)" == "Linux" ]; then
  print_colored "$YELLOW" "Linux detected"
  confirm "This script will prepare the system for NixOS installation. Do you want to continue?"

  # Check for necessary tools (parted, mkfs.fat, mkfs.ext4)
  command -v parted >/dev/null 2>&1 || {
    echo "parted is not installed. Aborting."
    exit 1
  }
  command -v mkfs.fat >/dev/null 2>&1 || {
    echo "mkfs.fat is not installed. Aborting."
    exit 1
  }
  command -v mkfs.ext4 >/dev/null 2>&1 || {
    echo "mkfs.ext4 is not installed. Aborting."
    exit 1
  }

  # Prompt user to enter disk if not provided as a command-line argument
  if [ -z "$DISK" ]; then
    print_header "Available Disks"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -w disk
    read -p "Enter the disk to partition (e.g., /dev/nvme0n1): " DISK
  fi

  # Dynamic partition name based on disk type (nvme vs non-nvme)
  if [[ "$DISK" =~ nvme ]]; then
    PART1="${DISK}p1"
    PART2="${DISK}p2"
  else
    PART1="${DISK}1"
    PART2="${DISK}2"
  fi

  print_header "Verifying Disk"
  confirm "Are you sure you want to format $DISK? This will erase all data on the disk."

  # Partitioning the disk
  print_header "Partitioning Disk"
  if parted $DISK -- mklabel gpt &&
    parted $DISK -- mkpart ESP fat32 1MiB 512MiB &&
    parted $DISK -- set 1 boot on &&
    parted $DISK -- mkpart Nix 512MiB 100%; then
    sync # Ensure changes are flushed to disk
    print_colored "$GREEN" "Disk partitioned successfully."
  else
    print_colored "$RED" "Error partitioning disk."
    exit 1
  fi

  # Check disk labeling to verify partitions were created
  if ! lsblk | grep -q "${PART1}"; then
    print_colored "$RED" "Partition ${PART1} not found."
    exit 1
  fi

  print_header "Creating Filesystems"
  if mkfs.fat -F32 -n BOOT $PART1 && mkfs.ext4 -F -L NIX $PART2; then
    sync # Ensure filesystems are created properly
    print_colored "$GREEN" "Filesystems created successfully."
  else
    print_colored "$RED" "Error creating filesystems."
    exit 1
  fi

  # Retrieving UUIDs for the partitions
  print_header "Retrieving UUIDs"
  BOOT_UUID=$(blkid -s UUID -o value $PART1)
  NIX_UUID=$(blkid -s UUID -o value $PART2)

  if [ -z "$BOOT_UUID" ] || [ -z "$NIX_UUID" ]; then
    print_colored "$RED" "Error retrieving UUIDs."
    exit 1
  fi

  # Using tmpfs for the /mnt directory
  print_header "Using tmpfs for /mnt"
  mount -t tmpfs none /mnt

  # Mounting filesystems
  print_header "Mounting Filesystems"
  if mkdir -pv /mnt/boot && mount UUID=$NIX_UUID /mnt && mount UUID=$BOOT_UUID /mnt/boot; then
    print_colored "$GREEN" "Filesystems mounted successfully."
  else
    print_colored "$RED" "Failed to mount filesystems. Root partition UUID: $NIX_UUID, Boot partition UUID: $BOOT_UUID"
    exit 1
  fi

  print_colored "$GREEN" "All steps completed successfully. NixOS is now ready to be installed."
  echo -e "\nTo install NixOS configuration for your hostname, run the following command:"
  print_colored "$YELLOW" "sudo nixos-install --no-root-passwd --flake github:ranokay/dotfiles#hostname"

else
  # Unsupported OS error
  print_colored "$RED" "Unsupported operating system."
  exit 1
fi
