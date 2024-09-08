{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./_packages.nix
    ./_zsh.nix
  ];

  home = {
    username = "ranokay";
    homeDirectory = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isLinux "/home/ranokay")
      (lib.mkIf pkgs.stdenv.isDarwin "/Users/ranokay")
    ];
    stateVersion = "24.05";
    sessionVariables = lib.mkIf pkgs.stdenv.isDarwin {
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
    };
  };

  programs = {
    # git - version control
    git = {
      enable = true;
      # delta = {
      #   enable = true;
      # };
    };
    # fzf - fuzzy finder
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    # lsd - ls with preview
    lsd = {
      enable = true;
      enableAliases = true;
    };
    # direnv - load environment variables from .envrc
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    # fastfetch - system information
    fastfetch.enable = true;
  };

  # Nicely reload system units when changing configs
  # Self-note: nix-darwin seems to luckily ignore this setting
  systemd.user.startServices = "sd-switch";
}
