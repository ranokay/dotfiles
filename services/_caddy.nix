{
  config,
  pkgs,
  ...
}: {
	sops.secrets = {
		"cloudflare-zone-key" = {};
		"cloudflare-dns-key" = {};
	};

	services.caddy = {
		enable = true;
		package = (pkgs.callPackage "${builtins.fetchurl https://raw.githubusercontent.com/jpds/nixpkgs/a33b02fa9d664f31dadc8a874eb1a5dbaa9f4ecf/pkgs/servers/caddy/default.nix}" {
			externalPlugins = [
				{ name = "caddy-dns/cloudflare"; repo = "github.com/caddy-dns/cloudflare"; version = "89f16b99c18ef49c8bb470a82f895bce01cbaece"; }
				# Commit on Jul 3, 2024 Version: 89f16b9
			];
			vendorHash = "sha256-YNcQtjPGQ0XMSog+sWlH4lG/QdbdI0Lyh/fUGqQUFaY=";  # Add this as explained in https://github.com/NixOS/nixpkgs/pull/259275#issuecomment-1763478985
		});
		globalConfig = ''
			dns cloudflare {
				CF_ZONE_TOKEN ${config.sops.secrets."cloudflare-zone-key".path}
				CF_API_TOKEN ${config.sops.secrets."cloudflare-dns-key".path}
			}
		'';
	};

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/caddy"
    ];
  };
}