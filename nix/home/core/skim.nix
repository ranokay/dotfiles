# Command-line fuzzy finder written in Rust.
# https://github.com/lotabout/skim
{...}: {
  programs.skim = {
    enable = true;
    enableBashIntegration = true;
  };
}
