{
  description = "Personal Nix Configuration";

  inputs = {
    # Use Determinate Systems nixpkgs for better stability and performance
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";

    # Use Determinate Systems flake utils for better development experience
    flake-utils.url = "https://flakehub.com/f/numtide/flake-utils/*";

    home-manager.url = "https://flakehub.com/f/nix-community/home-manager/*";

    darwin.url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.2505.2185";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    darwin,
    home-manager,
    ...
  } @ inputs: let
    # Define your systems and user info
    systems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux"];

    # Personal information - could be moved to a separate file
    userConfig = {
      username = "ranokay";
      email = "github@ranokay.com";
    };

    # Helper function to create system configurations
    mkSystem = {
      hostname,
      system,
      modules ? [],
      homeModules ? [],
      specialArgs ? {},
    }: let
      baseSpecialArgs = inputs // userConfig // {inherit hostname system;} // specialArgs;
    in {
      ${hostname} =
        if (nixpkgs.lib.hasSuffix "darwin" system)
        then
          darwin.lib.darwinSystem {
            inherit system;
            specialArgs = baseSpecialArgs;
            modules =
              [
                ./hosts/${hostname}
                ./profiles/base
                ./profiles/darwin
              ]
              ++ modules
              ++ [
                home-manager.darwinModules.home-manager
                {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    extraSpecialArgs = baseSpecialArgs;
                    users.${userConfig.username} = {
                      imports =
                        [
                          ./home/profiles/base
                        ]
                        ++ homeModules;
                    };
                  };
                }
              ];
          }
        else
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = baseSpecialArgs;
            modules =
              [
                ./hosts/${hostname}
                ./profiles/base
                ./profiles/nixos
              ]
              ++ modules
              ++ [
                home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    extraSpecialArgs = baseSpecialArgs;
                    users.${userConfig.username} = {
                      imports =
                        [
                          ./home/profiles/base
                        ]
                        ++ homeModules;
                    };
                  };
                }
              ];
          };
    };
  in {
    # Darwin configurations
    darwinConfigurations = nixpkgs.lib.mkMerge [
      (mkSystem {
        hostname = "mbp";
        system = "aarch64-darwin";
        homeModules = [
          ./home/profiles/development
          ./home/profiles/darwin
        ];
      })
    ];

    # NixOS configurations (for future use)
    nixosConfigurations = nixpkgs.lib.mkMerge [
      # Example server configuration (commented out for now)
      # (mkSystem {
      #   hostname = "server";
      #   system = "x86_64-linux";
      #   homeModules = [
      #     ./home/profiles/server
      #   ];
      # })
    ];

    # Development shells for each system
    devShells = flake-utils.lib.eachSystemMap systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          just
          alejandra
          nil
        ];
        shellHook = ''
          echo "Nix development environment loaded"
          echo "Available commands: just --list"
        '';
      };
    });

    # Formatter for all systems
    formatter = flake-utils.lib.eachSystemMap systems (
      system:
        nixpkgs.legacyPackages.${system}.alejandra
    );
  };
}
