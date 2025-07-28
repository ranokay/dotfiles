# A modern replacement for ls.
# https://github.com/eza-community/eza
_: {
  programs.eza = {
    enable = true;
    git = true;
    icons = "always";
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
