{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix

    ./../../modules/nixos/base.nix
    ./../../modules/nixos/remote-unlock.nix
    ./../../modules/nixos/auto-update.nix

    ./../../services/tailscale.nix
    ./../../services/netdata.nix
    ./../../services/nextcloud.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      ranokay = {
        imports = [
          ./../../modules/home-manager/base.nix
        ];
      };
    };
  };

  networking = {
    hostName = "oxyhome";
    interfaces = {
      enp0s20f0u1 = {
        ipv4.addresses = [
          {
            address = "192.168.0.100";
            prefixLength = 24;
          }
        ];
      };
    defaultGateway = "192.168.0.1";
    };
  };
}
