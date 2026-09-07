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

  # Public half of the key nix-daemon (running as root) uses to reach huala.
  # The private half lives outside the repo, at cfg.client.sshKey.
  builderKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRKWIp7YgXikaFW3MNnYSDHJlhxzbOW0MKacw5r2NE4 nixremote@builders";
in
{
  options.remoteBuilder = {
    server.enable = lib.mkEnableOption "accepting distributed builds on this host";

    server.authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ builderKey ];
      description = "Keys allowed to submit builds as the nixremote user.";
    };

    server.maxJobs = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Builds this host runs in parallel for its clients.";
    };

    client.enable = lib.mkEnableOption "offloading builds to ${builderHost}";

    client.sshKey = lib.mkOption {
      type = lib.types.path;
      default = "/root/.ssh/nixremote_ed25519";
      description = ''
        Private key nix-daemon uses to reach ${builderHost}. Not managed by
        this flake -- copy it into place out of band.
      '';
    };
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
        openssh.authorizedKeys.keys = cfg.server.authorizedKeys;
      };

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
          sshKey = toString cfg.client.sshKey;
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

      # nix-daemon runs as root and non-interactively: the host key has to be
      # known up front or every offloaded build fails to connect.
      programs.ssh.knownHosts.${builderHost}.publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIIaWsaSj2r1DhFf7oNXB0+idIB+9JOlzTj84aCiPuJw";
    })
  ];
}
