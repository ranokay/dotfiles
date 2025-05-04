{...}: {
  programs.eza = {
    enable = true;
    git = true;
    icons = "always";
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
