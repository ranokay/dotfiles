{config, ...}: {
  boot = {
    kernelParams = ["ip=dhcp"];
    initrd.network = {
      enable = true;
      ssh = {
        enable = true;
        shell = "/bin/cryptsetup-askpass";
        authorizedKeys = config.users.users.ranokay.openssh.authorizedKeys.keys;
        hostKeys = ["/nix/secret/initrd/ssh_host_ed25519_key"];
      };
    };
  };
}
