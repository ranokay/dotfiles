_: {
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      cleanup = "zap"; # Uninstalls all formulae (and related files) not listed in the generated Brewfile
    };

    masApps = {
      # Mac App Store applications
      # Uncomment and add App Store apps as needed
      # Xcode = 497799835;
      # "1Password for Safari" = 1569813296;
      # Clamshell = 6477896729;
      # Codye = 1516894961;
    };

    taps = [
      # Add additional taps here
    ];

    brews = [
      "blacktop/tap/lporg"
    ];

    casks = [
      # Browsers
      "zen-browser"
      "brave-browser"
      "arc"

      # Development tools
      "cursor"
      "visual-studio-code"
      "zed"
      "jetbrains-toolbox"
      "orbstack"
      "httpie"

      # Design tools
      "figma"

      # Communication
      "telegram"
      "legcord"
      "microsoft-teams"

      # Media
      "iina"
      "spotify"
      "obs"

      # Productivity
      "raycast"
      "notion"
      "obsidian"
      "nextcloud"
      "1password"
      "rectangle-pro"

      # System utilities
      "stats"
      "devcleaner"
      "pearcleaner"
      "aldente"
      "bartender"
      "lulu"
      "betterdisplay"
      "karabiner-elements"
      "keka"
      "logi-options+"
      "music-decoy"
      "notchnook"
      "shottr"
      "trae"
      "yubico-authenticator"
      "prefs-editor"
      "tailscale"

      # File sharing
      "localsend"
      "free-download-manager"
      "anydesk"

      # Virtualization
      "utm"
      "vmware-fusion"
      "crossover"

      # Development/Mobile
      "expo-orbit"
      "balenaetcher"

      # Gaming
      "nvidia-geforce-now"
      "weka"

      # Terminal/Shell
      "warp"
      "ghostty"
    ];
  };
}
