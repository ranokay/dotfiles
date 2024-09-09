{
  config,
  pkgs,
  ...
}: let
  caddyWithPlugins = pkgs.caddy.override {
    buildGoModule = args:
      pkgs.buildGoModule (args
        // {
          vendorSha256 = null;
          overrideModAttrs = _: {
            postBuild = ''
              go install github.com/caddy-dns/cloudflare@latest
            '';
          };
        });
  };
in {
  services.caddy = {
    enable = true;
    package = caddyWithPlugins;
    configFile = pkgs.writeText "Caddyfile" ''
      (cloudflare) {
        tls {
          dns cloudflare {
            zone_token {$env.cloudflare_zone_key}
            api_token {$env.cloudflare_api_key}
          }
        }
      }

      # navidrome
      # navidrome.proxmox.oxystack.com {
      #   reverse_proxy http://192.168.0.102:4533
      #   import cloudflare
      # }

      # nextcloud
      nextcloud.home.oxystack.com {
        reverse_proxy https://192.168.0.100:8080 {
          transport http {
            tls_insecure_skip_verify
          }
        }
        import cloudflare
      }

      # huawei
      huawei.home.oxystack.com {
        reverse_proxy http://192.168.0.1
        import cloudflare
      }
    '';
  };

  environment.systemPackages = [caddyWithPlugins];

  sops.secrets = {
    cloudflare_zone_key = {};
    cloudflare_api_key = {};
  };

  systemd.services.caddy.serviceConfig = {
    EnvironmentFile = [
      config.sops.secrets.cloudflare_zone_key.path
      config.sops.secrets.cloudflare_api_key.path
    ];
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/caddy"
    ];
  };
}
