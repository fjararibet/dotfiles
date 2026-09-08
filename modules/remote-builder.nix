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
      # Dedicated build account: huala refuses root logins, and builds have no
      # business running as fjara.
      users.groups.nixremote = { };
      users.users.nixremote = {
        isNormalUser = true;
        group = "nixremote";
        description = "Distributed nix builds";
        shell = pkgs.bashInteractive;
      };

      # Tailscale authenticates clients using their tailnet identity. The
      # tailnet SSH policy grants non-interactive access as nixremote.
      services.tailscale.extraSetFlags = [ "--ssh" ];

      # Trusted so clients can push unsigned derivations and pull the results back.
      nix.settings.trusted-users = [ "nixremote" ];
      nix.settings.max-jobs = cfg.server.maxJobs;
    })

    (lib.mkIf cfg.client.enable {
      nix.distributedBuilds = true;

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
