# Fast cd command that learns your habits.
# https://github.com/ajeetdsouza/zoxide
{...}: {
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };
}
