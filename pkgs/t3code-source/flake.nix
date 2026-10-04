{
  description = "T3 Code nightly desktop and server built from pinned upstream source";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    t3code-src = {
      url = "github:pingdotgg/t3code";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      t3code-src,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      overlay = final: prev: {
        t3code-source = final.callPackage ./package.nix { src = t3code-src; };
      };
    in
    {
      overlays.default = overlay;
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };
        in
        {
          default = pkgs.t3code-source;
          t3code = pkgs.t3code-source;
          unwrapped = pkgs.t3code-source.unwrapped;
          resource-monitor = pkgs.t3code-source.resourceMonitor;
          refresh-dependencies = pkgs.writeShellApplication {
            name = "refresh-t3code-dependencies";
            runtimeInputs = [
              pkgs.python3
              pkgs.nix
            ];
            text = ''exec python3 ${./refresh-dependencies.py} "$@"'';
          };
        }
      );
      apps = forAllSystems (
        system:
        let
          package = self.packages.${system}.default;
        in
        {
          default = {
            type = "app";
            program = "${package}/bin/t3code-desktop";
            meta.description = "Run the source-built T3 Code nightly desktop";
          };
          desktop = {
            type = "app";
            program = "${package}/bin/t3code-desktop";
            meta.description = "Run the source-built T3 Code nightly desktop";
          };
          t3 = {
            type = "app";
            program = "${package}/bin/t3";
            meta.description = "Run the source-built T3 Code nightly CLI";
          };
        }
      );
      checks = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          package = self.packages.${system}.default;
        in
        {
          cli = pkgs.runCommand "t3code-source-cli-check" { } ''
            ${package}/bin/t3 --version
            ${package}/bin/t3 serve --help > "$out"
            ${pkgs.nodejs}/bin/node ${./pty-check.cjs} ${package.unwrapped} ${pkgs.runtimeShell}
            ELECTRON_RUN_AS_NODE=1 ${pkgs.lib.getExe pkgs.electron_44} \
              ${./pty-check.cjs} ${package.unwrapped} ${pkgs.runtimeShell}
          '';
        }
      );
    };
}
