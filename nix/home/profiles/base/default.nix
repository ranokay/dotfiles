{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../git.nix
    ../../starship.nix
    ../../zsh.nix

    ../../core/packages.nix
    ../../core/eza.nix
    ../../core/skim.nix
    ../../core/zoxide.nix
  ];

  home = {
    inherit username;
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${username}"
      else "/home/${username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with
    stateVersion = "25.05";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
