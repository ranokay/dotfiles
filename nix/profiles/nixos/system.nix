{
  lib,
  pkgs,
  ...
}: {
  # Bootloader configuration (example - adjust based on your hardware)
  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    efi.canTouchEfiVariables = lib.mkDefault true;
  };

  # Enable firmware updates
  services = {
    fwupd.enable = true;

    # Enable thermald for Intel CPUs
    thermald.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isx86_64;

    # Power management
    powerManagement.enable = true;
    power-profiles-daemon.enable = true;

    # Enable CUPS for printing
    printing.enable = lib.mkDefault true;

    # X11/Wayland configuration (disabled by default for servers)
    xserver = {
      enable = lib.mkDefault false;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };

  # Enable Bluetooth (if needed)
  hardware.bluetooth = {
    enable = lib.mkDefault false;
    powerOnBoot = lib.mkDefault false;
  };

  # Console keymap
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty
  };

  # Systemd configuration
  systemd = {
    # Reduce systemd journal size
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';

    # Enable systemd in the initrd
    initrd.systemd.enable = lib.mkDefault true;
  };
}
