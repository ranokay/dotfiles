{pkgs, ...}: {
  home.packages = with pkgs; [
    # Utility that combines the usability of The Silver Searcher with the raw speed of grep. https://github.com/BurntSushi/ripgrep
    ripgrep

    # Lightweight and flexible command-line JSON processor. https://stedolan.github.io/jq
    jq

    # Portable command-line YAML processor. https://github.com/mikefarah/yq
    yq-go

    # Command-line fuzzy finder written in Go. https://github.com/junegunn/fzf
    fzf

    # Lightweight, multi-protocol, multi-source, command-line download utility. https://aria2.github.io/
    aria2

    # A utility for network discovery and security auditing. https://nmap.org/
    nmap

    # Render markdown on the CLI. https://github.com/charmbracelet/glow
    glow

    # Command line HTTP client whose goal is to make CLI human-friendly. https://httpie.io/
    httpie

    # Simple, fast and user-friendly alternative to find. https://github.com/sharkdp/fd
    fd

    # Cat(1) clone with syntax highlighting and Git integration. https://github.com/sharkdp/bat
    bat

    # GitHub CLI tool. https://cli.github.com/
    gh
  ];
}
