_: {
  # Enable flakes and new nix command
  nix = {
    settings = {
      # Enable flakes and new command
      experimental-features = ["nix-command" "flakes"];

      # Optimize storage and downloads
      auto-optimise-store = true;

      # Trust certain users to use nix
      trusted-users = ["root" "@admin"];

      # Builders and substituters
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # Garbage collection
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    # Allow packages with unfree or broken licenses
    allowUnfreePredicate = _: true;
  };
}
