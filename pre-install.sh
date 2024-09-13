#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
  local color=$1
  local message=$2
  echo -e "${color}${message}${NC}"
}

print_header() {
  local message=$1
  echo -e "\n${BLUE}==== $message ====${NC}"
}

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

check_command() {
  if ! "$@"; then
    print_colored "$RED" "Command failed: $*"
    exit 1
  fi
}

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
  --help)
    echo "Usage: $0 [--disk <disk>] [--auto-confirm]"
    echo "  --disk: Specify the disk to use for installation"
    echo "  --auto-confirm: Skip confirmation prompts"
    exit 0
    ;;
  *)
    print_colored "$RED" "Unknown option: $1"
    exit 1
    ;;
  esac
done

if [ "$(id -u)" -ne 0 ]; then
  print_colored "$RED" "This script must be run as root"
  exit 1
fi

if [ "$(uname)" == "Darwin" ]; then
  print_colored "$YELLOW" "macOS detected"
  confirm "This script will prepare the system for nix-darwin installation. Do you want to continue?"

  print_header "Checking for required tools (Xcode and Rosetta)"
  if [[ -e /Library/Developer/CommandLineTools/usr/bin/git ]]; then
    print_colored "$GREEN" "Xcode already installed."
  else
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
    check_command softwareupdate -i "$PROD" --verbose
    print_colored "$GREEN" "Xcode installed successfully."
  fi

  print_header "Installing Rosetta"
  if [[ $(uname -m) == 'arm64' ]]; then
    check_command softwareupdate --install-rosetta --agree-to-license
    print_colored "$GREEN" "Rosetta installed successfully."
  else
    print_colored "$YELLOW" "Rosetta installation skipped (not on ARM64)."
  fi

  print_header "Installing Nix"
  if command -v nix &>/dev/null; then
    print_colored "$YELLOW" "Nix is already installed. Skipping installation."
  else
    check_command curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  fi

  print_colored "$GREEN" "All steps completed successfully. nix-darwin is now ready to be installed."
  echo -e "\nTo install nix-darwin configuration, run the following commands:"
  print_colored "$YELLOW" ". /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  print_colored "$YELLOW" "nix run nix-darwin -- switch --flake github:ranokay/dotfiles#mac1"

elif [ "$(uname)" == "Linux" ]; then
  print_colored "$YELLOW" "Linux detected"
  confirm "This script will prepare the system for NixOS installation. Do you want to continue?"

  if [ -z "$DISK" ]; then
    print_header "Available Disks"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -w disk
    read -p "Enter the disk to partition (e.g., /dev/nvme0n1): " DISK

    print_header "Verifying Disk"
    confirm "Are you sure you want to format $DISK? This will erase all data on the disk."
  fi

  if [[ ! -e "$DISK" ]]; then
    print_colored "$RED" "Error: Disk $DISK does not exist."
    exit 1
  fi

  if [[ $DISK =~ "nvme" ]] || [[ $DISK =~ "loop" ]]; then
    PART1="${DISK}p1"
    PART2="${DISK}p2"
  else
    PART1="${DISK}1"
    PART2="${DISK}2"
  fi

  print_header "Partitioning Disk"
  check_command parted $DISK -- mklabel gpt
  check_command parted $DISK -- mkpart ESP fat32 1MiB 512MiB
  check_command parted $DISK -- set 1 boot on
  check_command parted $DISK -- mkpart Nix 512MiB 100%
  print_colored "$GREEN" "Disk partitioned successfully."

  print_header "Creating Filesystems"
  check_command mkfs.fat -F32 -n BOOT $PART1
  check_command mkfs.ext4 -F -L NIX $PART2
  sync
  print_colored "$GREEN" "Filesystems created successfully."

  print_header "Retrieving UUIDs"
  BOOT_UUID=$(blkid -s UUID -o value $PART1)
  NIX_UUID=$(blkid -s UUID -o value $PART2)

  if [ -z "$BOOT_UUID" ] || [ -z "$NIX_UUID" ]; then
    print_colored "$RED" "Error retrieving UUIDs."
    exit 1
  fi

  print_header "Using tmpfs for /mnt"
  check_command mount -t tmpfs none /mnt

  print_header "Mounting Filesystems"
  check_command mount UUID=$NIX_UUID /mnt
  check_command mkdir -pv /mnt/boot
  check_command mount UUID=$BOOT_UUID /mnt/boot
  print_colored "$GREEN" "Filesystems mounted successfully."

  print_colored "$GREEN" "All steps completed successfully. NixOS is now ready to be installed."
  echo -e "\nTo install NixOS configuration for your hostname, run the following command:"
  print_colored "$YELLOW" "sudo nixos-install --no-root-passwd --flake github:ranokay/dotfiles#hostname"

else
  print_colored "$RED" "Unsupported operating system."
  exit 1
fi
