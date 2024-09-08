{
  lib,
  pkgs,
  ...
}: {
  programs.ssh = {
    enable = true;
    extraConfig = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isLinux ''
        IdentityAgent "~/.1password/agent.sock"
      '')
      (lib.mkIf pkgs.stdenv.isDarwin ''
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      '')
    ];
  };

  programs.git = {
    userName = "ranokay";
    userEmail = "github@ranokay.com";
    signing = {
      # 1Password GitHub Commit Signing Key
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
