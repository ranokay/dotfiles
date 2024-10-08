{config, ...}: {
  sops.secrets.tailscale_authkey = {};

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.sops.secrets.tailscale_authkey.path;
    extraUpFlags = [
      # TODO: Add your Tailscale IPs here
      "--advertise-routes=10.0.0.0/8"
    ];
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/tailscale"
    ];
  };
}
