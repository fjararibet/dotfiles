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

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address on which the T3 Code server listens.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3773;
      description = "Port on which the T3 Code server listens.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Keep the user manager and server alive after the last login session ends.
    users.users.fjara.linger = true;

    # Nixified `t3 service install`. Run the packaged server directly instead
    # of installing an imperative unit and a self-updating launcher under ~/.t3.
    home-manager.users.fjara.systemd.user.services.t3code = {
      Unit = {
        Description = "T3 Code server";
        StartLimitIntervalSec = 300;
        StartLimitBurst = 5;
      };

      Service = {
        Type = "simple";
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
