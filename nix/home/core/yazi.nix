# Blazing fast terminal file manager written in Rust, based on async I/O.
# https://github.com/sxyazi/yazi
_: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_dir_first = true;
      };
    };
  };
}
