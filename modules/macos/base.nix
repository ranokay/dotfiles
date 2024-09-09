{pkgs, ...}: {
  imports = [
    ./_dock.nix
    ./_packages.nix
  ];

  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@admin"
      ];
    };
  };

  programs.zsh.enable = true;
  security.pam.enableSudoTouchIdAuth = true;

  services = {
    nix-daemon.enable = true;
    tailscale.enable = true;
  };

  users.users.ranokay.home = "/Users/ranokay";

  system = {
    startup.chime = false;
    defaults = {
      loginwindow.LoginwindowText = "If lost, contact contact@ranokay.com";

      dock = {
        autohide = true;
        mru-spaces = false;
        tilesize = 96;
        wvous-br-corner = 4;
        wvous-bl-corner = 11;
        wvous-tr-corner = 5;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "clmv";
      };

      menuExtraClock = {
        ShowSeconds = true;
        Show24Hour = true;
        ShowAMPM = false;
      };

      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        # inspo: https://apple.stackexchange.com/questions/261163/default-value-for-nsglobaldomain-initialkeyrepeat
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
      };
    };
  };

  local = {
    dock = {
      enable = true;
      entries = [
        {path = "/System/Applications/Launchpad.app";}
        {path = "/Applications/Visual Studio Code.app";}
        {path = "/System/Applications/System Settings.app";}
      ];
    };
  };

  system.stateVersion = 4;
}
