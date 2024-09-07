{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ".." = "cd ..";
      cat = "bat --style=plain --theme=base16 --paging=never ";
      e = "eza ";
    };
    # inspo: https://discourse.nixos.org/t/brew-not-on-path-on-m1-mac/26770/4
    initExtra = ''
      fortune

      if [[ $(uname -m) == 'arm64' ]] && [[ $(uname -s) == 'Darwin' ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
    '';
    plugins = [
    ];
  };
}
