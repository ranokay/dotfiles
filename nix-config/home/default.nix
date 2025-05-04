{username, ...}: {
  imports = [
    ./zsh.nix
    ./git.nix
    ./starship.nix

    ./core/packages.nix
    ./core/eza.nix
    ./core/yazi.nix
    ./core/skim.nix
    ./core/zoxide.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "25.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
