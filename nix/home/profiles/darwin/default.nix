_: {
  imports = [
    ../../core/yazi.nix
  ];

  # Darwin-specific shell aliases
  home.shellAliases = {
    # macOS specific aliases
    "flush-dns" = "sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
    "show-hidden" = "defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder";
    "hide-hidden" = "defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder";
  };
}
