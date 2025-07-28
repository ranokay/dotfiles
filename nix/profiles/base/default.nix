{
  lib,
  hostname,
  ...
}: {
  # Import base modules that apply to all systems
  imports = [
    ./nix-core.nix
    ./users.nix
  ];

  # Set hostname and computer name
  networking.hostName = hostname;
  networking.computerName = hostname;

  # Set system state version (adjust as needed)
  system.stateVersion = lib.mkDefault "25.05";
}
