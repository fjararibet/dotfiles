{ config, lib, pkgs, ... }:

let
  cfg = config.t3code;
  waitForNetwork = pkgs.writeShellScript "t3code-wait-for-network" ''
    for ((attempt = 0; attempt < 60; attempt++)); do
      if ${pkgs.iproute2}/bin/ip -4 route get 1.1.1.1 >/dev/null 2>&1; then
        exit 0
      fi
      ${pkgs.coreutils}/bin/sleep 1
    done
  '';
in
{
  options.t3code = {
    enable = lib.mkEnableOption "the T3 Code server";

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

  config = lib.mkIf cfg.enable {
    # Nixified `t3 service install`. Run the packaged server directly instead
    # of installing an imperative unit and a self-updating launcher under ~/.t3.
    # Each user gets their own service in their own systemd user manager, so
    # multiple users can run independent instances on one machine (give each a
    # distinct `t3code.port`).
    #
    # For the service to survive logout and start at boot, the user needs
    # lingering enabled system-side: `users.users.<name>.linger = true` in the
    # NixOS configuration (equivalent to `loginctl enable-linger <name>`).
    systemd.user.services.t3code = {
      Unit = {
        Description = "T3 Code server";
        StartLimitIntervalSec = 300;
        StartLimitBurst = 5;
      };

      Service = {
        Type = "simple";
        ExecStartPre = waitForNetwork;
        ExecStart = "${pkgs.unstable.t3code}/bin/t3 serve --port ${toString cfg.port} --host ${lib.escapeShellArg cfg.host}";
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
