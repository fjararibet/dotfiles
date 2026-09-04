{ pkgs, paths, ... }:

let
  instantclient = pkgs.symlinkJoin {
    name = "oracle-instantclient-joined";
    paths = with pkgs.oracle-instantclient; [
      out
      lib
      dev
    ];
  };
in
{
  imports = [ (paths.home + "/common.nix") ];
  home.packages = with pkgs; [
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.cloud-firestore-emulator ])
    jre
    oracle-instantclient
  ];
  home.file."instantclient".source = instantclient;

  # Nixified `t3 service install`.  The upstream installer writes
  # ~/.config/systemd/user/t3code.service imperatively -- a directory Home
  # Manager owns -- and points ExecStart at a launcher that downloads node and
  # new t3 releases into ~/.t3 to self-update.  Both fight Nix, so run the
  # store-path `t3 serve` directly and let nixpkgs do the updating.  The unit
  # otherwise mirrors the one `renderBootServiceUnit` emits, minus its
  # `append:`-to-a-logfile redirection: journald already keeps the output
  # (`journalctl --user -u t3code`).
  systemd.user.services.t3code = {
    Unit = {
      Description = "T3 Code server";
      StartLimitIntervalSec = 300;
      StartLimitBurst = 5;
    };

    Service = {
      Type = "simple";
      # `serve` is the headless entry point: no browser, and it prints the
      # pairing details on startup.  It defaults to web mode, where leaving
      # --port unset makes it hunt for the first free port from 3773 upward --
      # pin it so the URL does not drift between restarts.  --host 0.0.0.0 is
      # web mode's own default, spelled out: it reaches Windows over WSL's
      # localhost forwarding and this box over the tailnet.
      ExecStart = "${pkgs.unstable.t3code}/bin/t3 serve --port 3773 --host 0.0.0.0";
      WorkingDirectory = "%h";
      Restart = "always";
      RestartSec = 5;
      # Agent sessions are spawned as children in a PTY; reap the whole cgroup
      # on stop, and do not let the kernel take the server down for a child's
      # memory use.
      KillMode = "mixed";
      OOMPolicy = "continue";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
