{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./system.nix
  ];

  # Enable NetworkManager for wireless support
  networking.networkmanager.enable = true;

  # Set time zone
  time.timeZone = lib.mkDefault "UTC";

  # Select internationalisation properties
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # Enable sound with pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable essential services
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  # Enable zsh globally
  programs.zsh.enable = true;

  # Allow sudo without password for wheel group (adjust as needed)
  security.sudo.wheelNeedsPassword = false;

  # Essential system packages for NixOS
  environment.systemPackages = with pkgs; [
    git
    just
    curl
    wget
    vim
    neovim
    htop
    btop
  ];
}
