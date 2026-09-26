{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.remoteBuilder;

  # Reached over Tailscale; huala has no stable LAN address.
  builderHost = "huala";
  cacheHost = "huala.triceratops-corn.ts.net";
  cachePublicKey = "huala-1:0UnPQk6av1mQhkXnfJ7QAHZVw8mNivWyteDbYxKNetM=";
in
{
  options.remoteBuilder = {
    server.enable = lib.mkEnableOption "accepting distributed builds on this host";

    server.maxJobs = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Builds this host runs in parallel for its clients.";
    };

    client.enable = lib.mkEnableOption "offloading builds to ${builderHost}";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.server.enable {
      # The signing key lives outside the flake; nix-serve receives it via
      # systemd credentials, not as a world-readable Nix store path.
      services.nix-serve = {
        enable = true;
        bindAddress = "100.81.95.87"; # huala's Tailscale address
        secretKeyFile = "/home/fjara/.local/share/nix-cache/secret-key";
      };

      # Dedicated build account: huala refuses root logins, and builds have no
      # business running as fjara.
      users.groups.nixremote = { };
      users.users.nixremote = {
        isNormalUser = true;
        group = "nixremote";
        description = "Distributed nix builds";
        shell = pkgs.bashInteractive;
      };

      # Trusted so clients can push unsigned derivations and pull the results back.
      nix.settings.trusted-users = [ "nixremote" ];
      nix.settings.max-jobs = cfg.server.maxJobs;
    })

    (lib.mkIf cfg.client.enable {
      nix.distributedBuilds = true;

      # Prefer huala's nix-serve cache; fall back to cache.nixos.org for paths
      # huala has not pre-built yet. Both advertise priority 30, so order decides.
      nix.settings.substituters = [ "http://${cacheHost}:5000" "https://cache.nixos.org" ];
      nix.settings.extra-trusted-public-keys = [ cachePublicKey ];

      # Let huala fetch from the caches itself instead of shipping paths to it.
      nix.settings.builders-use-substitutes = true;

      nix.buildMachines = [
        {
          hostName = builderHost;
          sshUser = "nixremote";
          protocol = "ssh-ng";
          systems = [ "x86_64-linux" ];
          maxJobs = 8;
          speedFactor = 2;
          supportedFeatures = [
            "big-parallel"
            "kvm"
            "nixos-test"
            "benchmark"
          ];
        }
      ];
    })
  ];
}
