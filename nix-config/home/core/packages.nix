{pkgs, ...}: {
  home.packages = with pkgs; [
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    # yq-go # yaml processer https://github.com/mikefarah/yq
    fzf # A command-line fuzzy finder
    wget
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    nmap # A utility for network discovery and security auditing
    tree
    glow # markdown previewer in terminal
    httpie
    fd
    bat
    gh
  ];
}
