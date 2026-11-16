{ config, pkgs, paths, ... }:
let
  zapzapWayland = pkgs.symlinkJoin {
    name = "zapzap-wayland";
    paths = [ pkgs.zapzap ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/zapzap --set QT_QPA_PLATFORM wayland
    '';
  };
in {
  imports = [
    (paths.home + "/common.nix")
    (paths.home + "/desktop.nix")
  ];

  # Keep T3 Code independently updatable through fjara's Nix profile.
  xdg.desktopEntries."com.t3tools.T3Code" = {
    name = "T3 Code (Alpha)";
    comment = "Minimal web GUI for coding agents";
    exec = "${config.home.homeDirectory}/.nix-profile/bin/t3code-desktop %U";
    icon = "t3code";
    terminal = false;
    categories = [ "Development" ];
    mimeType = [ "x-scheme-handler/t3code" ];
    settings.StartupWMClass = "t3code";
  };

  systemd.user.services.t3code = {
    Unit = {
      Description = "T3 Code server";
      StartLimitIntervalSec = 300;
      StartLimitBurst = 5;
    };
    Service = {
      Type = "simple";
      ExecStart = "${config.home.homeDirectory}/.nix-profile/bin/t3 __service-launcher";
      WorkingDirectory = "%h";
      Environment = [
        "T3CODE_HOME=${config.home.homeDirectory}/.t3"
        "T3_BOOT_SERVICE_UNIT=t3code.service"
        "PATH=${config.home.homeDirectory}/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin"
      ];
      KillMode = "mixed";
      OOMPolicy = "continue";
      Restart = "always";
      RestartSec = 5;
      CPUWeight = 1000;
      IOWeight = 1000;
      MemoryLow = "1536M";
      OOMScoreAdjust = 100;
      ManagedOOMPreference = "avoid";
      StandardOutput = "append:${config.home.homeDirectory}/.t3/userdata/logs/boot-service.log";
      StandardError = "append:${config.home.homeDirectory}/.t3/userdata/logs/boot-service.log";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Keep Rex independently updatable through `nix profile`; restart after upgrades.
  systemd.user.services.rex = {
    Unit.Description = "Rex server";
    Service = {
      ExecStart = "${config.home.homeDirectory}/.nix-profile/bin/rex server run";
      WorkingDirectory = "%h";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = [
        "PATH=${config.home.homeDirectory}/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin"
      ];
    };
    Install.WantedBy = [ "default.target" ];
  };

  home.packages = with pkgs; [
    qbittorrent
    cloudflared
    zapzapWayland
    unstable.osu-lazer-bin
    unstable.google-cloud-sdk
  ];
}
