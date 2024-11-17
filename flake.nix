{
  description = "Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:LnL7/nix-darwin";
    };
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

  outputs = {
    self,
    darwin,
    homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-bundle,
    alienator88,
    ...
  }: let
    configuration = {
      pkgs,
      config,
      ...
    }: {
      nixpkgs = {
        config.allowUnfree = true;
        hostPlatform = "aarch64-darwin";
      };
      environment = {
        systemPackages = with pkgs; [
          # Development
          alejandra # The Uncompromising Nix Code Formatter
          statix # Lints and suggestions for the nix programming language
          nil # Language server for Nix
          nixd # Language server for Nix
          just
          neovim
          gh
          bat
        ];

        variables = {
          HOMEBREW_VERBOSE = "1";
          HOMEBREW_NO_EMOJI = "1";
          HOMEBREW_DEVELOPER = "1";
        };
      };

      homebrew = {
        enable = true;
        taps = builtins.attrNames config.nix-homebrew.taps;
        casks = [
          # Development
          "visual-studio-code"
          "jetbrains-toolbox"
          "cursor"
          "zed"
          "orbstack"
          "expo-orbit"

          # Network
          "lulu"
          "tailscale"

          # Design
          "figma"
          "figma-agent"

          # Database
          "dataflare"

          # Virtualization
          "vmware-fusion"
          "whisky"
          "crossover"

          # Terminal
          "warp"

          # Media
          "vlc"
          "spotify"

          # Communication
          # "legcord" # Discord client
          "notion"
          "telegram"
          "microsoft-teams"
          "lunatask"

          # Cloud
          "nextcloud"

          # Remote Desktop
          "rustdesk"
          "anydesk"

          # File Transfer
          "free-download-manager"

          # Gaming
          "nvidia-geforce-now"
          "steam"
          "epic-games"

          # Security
          "1password"
          "1password-cli"
          "yubico-authenticator"

          # Browsers
          "arc"
          "brave-browser"
          "zen-browser"

          # AI
          "claude"

          # Utilities
          "the-unarchiver"
          "sentinel-app" # A GUI for controlling Gatekeeper, unquarantining apps and more.
          "aldente"
          "betterdisplay"
          "raycast"
          "bartender"
          "shottr"
          "cleanmymac"
          "rectangle-pro"
          "balenaetcher"
          "logi-options+"
        ];
        masApps = {
          "Clamshell" = 6477896729;
          "1Password for Safari" = 1569813296;
        };
        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "uninstall";
          extraFlags = [
            "--force" # Add force flag to handle existing installations
            "--verbose"
            "--debug"
          ];
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

      system = {
        # activationScripts.launchpadLayout.text = ''
        #   # Set the Launchpad columns and rows
        #   defaults write com.apple.dock springboard-columns -int 10
        #   defaults write com.apple.dock springboard-rows -int 6

        #   # Restart the Dock to apply changes
        #   killall Dock
        # '';
        defaults = {
          dock = {
            autohide = true;
            autohide-delay = 0.0; # Make the dock appear instantly
            autohide-time-modifier = 0.4; # Smoother animation
            persistent-apps = [];
            persistent-others = [];
            magnification = true;
            largesize = 52;
            tilesize = 32;
            showhidden = true;
            show-recents = false; # Disable recent applications
            static-only = true; # Only show applications that are open
            wvous-bl-corner = 4; # Bottom left corner - Desktop
            wvous-br-corner = 3; # Bottom right corner - Mission Control
            wvous-tl-corner = 11; # Top left corner - Launchpad
            wvous-tr-corner = 2; # Top right corner - Application Windows
          };
          finder = {
            FXPreferredViewStyle = "Nlsv"; # List view
            _FXShowPosixPathInTitle = false; # Show the full POSIX filepath in the window title
            _FXSortFoldersFirst = true; # Keep folders on top when sorting by name
            FXDefaultSearchScope = "SCcf"; # Change the default search scope to current folder
            ShowPathbar = true; # Show path breadcrumbs
            ShowStatusBar = true; # Show status bar at bottom
            AppleShowAllFiles = true;
            AppleShowAllExtensions = true;
          };
          loginwindow = {
            LoginwindowText = "contact@ranokay.com"; # Text to be shown on the login window
            GuestEnabled = false; # Allow users to login to the machine as guests
          };
          LaunchServices = {
            LSQuarantine = false; # Disable the "Are you sure you want to open this application?" dialog
          };
          NSGlobalDomain = {
            AppleShowAllExtensions = true;
            AppleICUForce24HourTime = true;
            ApplePressAndHoldEnabled = false; # Disable press-and-hold for keys in favor of key repeat
            AppleInterfaceStyle = "Dark";
            KeyRepeat = 2;
            InitialKeyRepeat = 15;
            "com.apple.mouse.tapBehavior" = 1; # Enables tap to click
          };
          trackpad = {
            Clicking = true; # Enable tap to click
            TrackpadThreeFingerDrag = true; # Enable three finger drag
          };
        };

        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToEscape = true;
        };
        # Set Git commit hash for darwin-version.
        configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        stateVersion = 5;
      };
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."mbp" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
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
