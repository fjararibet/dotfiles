{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.t3code;
in
{
  options.t3code = {
    enable = lib.mkEnableOption "the T3 Code server";

    profileInstallable = lib.mkOption {
      type = lib.types.str;
      default = "github:limwa/nix-t3code#t3code";
      description = "Installable used to bootstrap an empty user profile; existing installations are never upgraded during activation.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address on which the T3 Code server listens.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3773;
      description = "Port on which the T3 Code server listens. Pick a port unique per user when several users run a server on the same machine.";
    };
  };

  config = {
    # Bootstrap once, as the owning user. The system closure
    # contains only this installable string, never the T3 Code package.
    home.activation.t3codeProfile = lib.hm.dag.entryBetween [ "reloadSystemd" ] [ "writeBoundary" ] ''
      if [ ! -x "$HOME/.nix-profile/bin/t3" ]; then
        run ${pkgs.nix}/bin/nix profile add ${lib.escapeShellArg cfg.profileInstallable}
      fi
    '';

    # Nixified `t3 service install`. Run the profile's server directly instead
    # of installing an imperative unit and a self-updating launcher under ~/.t3.
    # Each user gets their own service in their own systemd user manager, so
    # multiple users can run independent instances on one machine (give each a
    # distinct `t3code.port`).
    #
    # For the service to survive logout and start at boot, the user needs
    # lingering enabled system-side: `users.users.<name>.linger = true` in the
    # NixOS configuration (equivalent to `loginctl enable-linger <name>`).
    systemd.user.services.t3code = lib.mkIf cfg.enable {
      Unit = {
        Description = "T3 Code server";
        StartLimitIntervalSec = 300;
        StartLimitBurst = 5;
      };

      Service = {
        Type = "simple";
        ExecStart = "${config.home.homeDirectory}/.nix-profile/bin/t3 serve --port ${toString cfg.port} --host ${lib.escapeShellArg cfg.host}";
        WorkingDirectory = "%h";
        Restart = "always";
        RestartSec = 5;
        KillMode = "mixed";
        OOMPolicy = "continue";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
