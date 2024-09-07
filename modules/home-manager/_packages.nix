{
  pkgs,
  osConfig,
  ...
}: {
  home = {
    packages = with pkgs;
      [
        bat
        btop
        croc
        gdu
        jdupes
        wormhole-william
      ]
      # Below packages are for development and therefore excluded from servers
      # inspo: https://discourse.nixos.org/t/how-to-use-hostname-in-a-path/42612/3
      ++ (
        if builtins.substring 0 3 osConfig.networking.hostName != "oxyhome"
        then [
          alejandra
          bun
          # devenv
          # doppler
          # flyctl
          # just
          # nil
          nixos-rebuild # need for macOS
          nodejs
          sops
          statix
        ]
        else []
      );
  };
}
