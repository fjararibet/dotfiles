{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-neovim.url = "github:NixOS/nixpkgs/fd1462031fdee08f65fd0b4c6b64e22239a77870";
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
    # Backport T3 Code's user service without updating Home Manager for every host.
    home-manager-t3code = {
      url = "file+https://raw.githubusercontent.com/nix-community/home-manager/2f5ab4a8feca1441f3146bec67d7f0f07c3cffee/modules/programs/t3code.nix";
      flake = false;
    };
    ttyp = {
      url = "github:fjararibet/ttyp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, ... }:
    let
      lib = inputs.nixpkgs.lib;

      paths = {
        config = ./config;
        home = ./home;
        modules = ./modules;
      };

      unstableOverlay = final: _prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (final) config;
          inherit (final.stdenv.hostPlatform) system;
        };
      };

      ttypOverlay = inputs.ttyp.overlays.default;

      mkHost =
        {
          hostname,
          system ? "x86_64-linux",
          mkSystem,
          platformModules,
        }:
        mkSystem {
          specialArgs = {
            inherit inputs paths;
          };

          modules = [
            {
              nixpkgs.hostPlatform = system;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [
                unstableOverlay
                ttypOverlay
              ];
            }
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs paths;
              };
              home-manager.users.fjara = import ./hosts/${hostname}/home.nix;
            }
            ./hosts/${hostname}/configuration.nix
          ] ++ platformModules;
        };
    in
    {
      darwinConfigurations.loica = mkHost {
        hostname = "loica";
        system = "aarch64-darwin";
        mkSystem = inputs.nix-darwin.lib.darwinSystem;
        platformModules = [
          inputs.home-manager.darwinModules.home-manager
          inputs.nix-homebrew.darwinModules.nix-homebrew
        ];
      };

      nixosConfigurations = lib.genAttrs [ "huala" "pudu" "fragata" ] (
        hostname: mkHost {
          inherit hostname;
          mkSystem = lib.nixosSystem;
          platformModules = [ inputs.home-manager.nixosModules.home-manager ];
        }
      );
    };
}
