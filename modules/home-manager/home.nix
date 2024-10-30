{
  lib,
  pkgs,
  ...
}: {
  home.username = "ranokay";
  home.homeDirectory = "/Users/ranokay";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Yuuta";
    userEmail = "github@ranokay.com";
    signing = {
      # 1Password SSH GitHub Commit Signing
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOlQ9WC58WUVNYtM0tL1YJHDtCMpnLBhtZ3UcQH3dwj";
      signByDefault = true;
    };
    extraConfig = {
      gpg = {format = "ssh";};
      gpg."ssh".program = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isLinux "${pkgs._1password-gui}/bin/op-ssh-sign")
        (lib.mkIf pkgs.stdenv.isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign")
      ];
    };
  };
}
