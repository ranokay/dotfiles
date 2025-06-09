{...}: {
  nix.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
