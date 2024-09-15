{
  imports = [
    ./_packages.nix
  ];

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      # 1Password NixOS ISO Key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6IDrLYme7Jz4omKXvFBGoSseC+TLJZtmIIJe4VhJTC"
    ];
  };

  programs.bash.shellAliases = {
    install = "sudo bash -c \"$(curl -fsSL https://raw.githubusercontent.com/ranokay/dotfiles/main/pre-install.sh)\"";
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "24.05";
}
