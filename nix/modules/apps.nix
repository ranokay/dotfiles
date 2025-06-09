{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    just
  ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      cleanup = "zap"; # Uninstalls all formulae(and related files) not listed in the generated Brewfile
    };

    masApps = {
      # Xcode = 497799835;
      # "1Password for Safari" = 1569813296;
      # Clamshell = 6477896729;
      # Codye = 1516894961;
    };

    taps = [
    ];

    brews = [
      "blacktop/tap/lporg"
    ];

    casks = [
      "zen-browser"
      "brave-browser"
      "arc"
      "devcleaner"
      "raindropio"
      "telegram"
      "legcord"
      "iina"
      "raycast"
      "stats"
      "cursor"
      "visual-studio-code"
      "figma"
      "expo-orbit"
      "localsend"
      "anydesk"
      "rustdesk"
      "free-download-manager"
      "prefs-editor"
      "orbstack"
      "balenaetcher"
      # "dataflare" # try dBeaver of DataGrip
      "crossover"
      "jetbrains-toolbox"
      "1password"
      "aldente"
      "bartender"
      "lulu"
      "betterdisplay"
      "karabiner-elements"
      "keka"
      "logi-options+"
      "microsoft-teams"
      # "mumuplayer"
      "music-decoy"
      "nextcloud"
      "notchnook"
      "notion"
      "nvidia-geforce-now"
      "obs"
      "rectangle-pro"
      "shottr"
      "spotify"
      "trae"
      "utm"
      "vmware-fusion"
      "warp"
      "ghostty"
      "weka"
      "yubico-authenticator"
      "zed"
      "httpie"
      "tailscale"
      "pearcleaner"
    ];
  };
}
