{config, ...}: {
  sops.secrets = {
    "cloudflare-api-email" = {};
    "cloudflare-api-key" = {};
  };

  # inspo: https://carjorvaz.com/posts/setting-up-wildcard-lets-encrypt-certificates-on-nixos/
  security.acme = {
    acceptTerms = true;
    defaults.email = "oxyhome@ranokay.com";

    certs."home.oxystack.com" = {
      group = config.services.caddy.group;

      domain = "home.oxystack.com";
      extraDomainNames = ["*.home.oxystack.com"];
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      # inspo: https://go-acme.github.io/lego/dns/cloudflare/
      credentialFiles = {
        "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare-api-key".path;
      };
    };
  };

  # networking.firewall.allowedTCPPorts = [
  #   80
  #   443
  # ];

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/acme"
    ];
  };
}
