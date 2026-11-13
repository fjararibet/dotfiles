{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-neovim.url = "github:NixOS/nixpkgs/fd1462031fdee08f65fd0b4c6b64e22239a77870";
    nixpkgs-sway-working.url = "github:NixOS/nixpkgs/f3d24765175719ad0e816a3d5dcb8e84c11bd842";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ttyp = {
      url = "github:fjararibet/ttyp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib;

      paths = {
        config = ./config;
        home = ./home;
        modules = ./modules;
      };

      unstableOverlay = final: _prev: {
        unstable = import nixpkgs-unstable {
          inherit (final) config;
          inherit (final.stdenv.hostPlatform) system;
        };
      };

      ttypOverlay = inputs.ttyp.overlays.default;

      mkHomeConfig =
        {
          system ? "x86_64-linux",
          modules ? [ ],
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              unstableOverlay
              ttypOverlay
            ];
          };

          extraSpecialArgs = {
            inherit inputs paths;
          };

          modules = modules;
        };

      mkHost =
        {
          hostname,
          system ? "x86_64-linux",
          modules ? [ ],
          specialArgs ? { },
        }:
        lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs paths;
          }
          // specialArgs;

          modules = modules ++ [
            {
              nixpkgs.overlays = [
                unstableOverlay
                ttypOverlay
              ];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs paths;
              };
              home-manager.users.fjara = import ./hosts/${hostname}/home.nix;
            }
            ./hosts/${hostname}/configuration.nix
          ];
        };
    in
    {
      darwinConfigurations.loica = inputs.nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs paths; };
        modules = [
          ./hosts/loica/configuration.nix
          inputs.nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [ unstableOverlay ttypOverlay ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs paths; };
            home-manager.users.fjara = import ./hosts/loica/home.nix;
          }
        ];
      };

      nixosConfigurations = {
        huala = mkHost {
          hostname = "huala";
        };
        pudu = mkHost {
          hostname = "pudu";
        };
        fragata = mkHost {
          hostname = "fragata";
        };
      };

      homeManagerModules.default = ./home/common.nix;
      homeModules.default = ./home/common.nix;

      homeConfigurations = {
        fjara = mkHomeConfig {
          modules = [
            ./home/common.nix
            ./home/generic-linux.nix
          ];
        };
        huala = mkHomeConfig {
          modules = [ ./hosts/huala/home.nix ];
        };
        pudu = mkHomeConfig {
          modules = [ ./hosts/pudu/home.nix ];
        };
        fragata = mkHomeConfig {
          modules = [ ./hosts/fragata/home.nix ];
        };
      };
    };
}
