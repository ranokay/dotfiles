{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    alienator88 = {
      url = "github:alienator88/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    darwin,
    nixpkgs,
    homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-bundle,
    alienator88,
    ...
  }: let
    configuration = {
      pkgs,
      lib,
      config,
      ...
    }: {
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = with pkgs; [
        alejandra # The Uncompromising Nix Code Formatter
        statix # Lints and suggestions for the nix programming language
        neovim
      ];

      homebrew = {
        enable = true;
        taps = builtins.attrNames config.nix-homebrew.taps;
        brews = [
          "mas"
        ];
        casks = [
          "the-unarchiver"
          "sentinel-app"
        ];
        masApps = {
          "Clamshell" = 6477896729;
          "1Password for Safari" = 1569813296;
        };
        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "zap";
        };
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true; # default shell on catalina
      # programs.fish.enable = true;

      system.defaults = {
        dock = {
          autohide = true;
          persistent-apps = [];
        };
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.KeyRepeat = 2;
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."mbp" = darwin.lib.darwinSystem {
      modules = [
        configuration
        homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "ranokay";
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
              "alienator88/homebrew-cask" = alienator88;
            };
            mutableTaps = false;
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."mbp".pkgs;
  };
}
