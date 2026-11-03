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
    (paths.home + "/t3code.nix")
  ];

  t3code.enable = true;
  t3code.profileManaged = true;
  # Preserve the deployed version during migration; upgrades use nix profile.
  t3code.profileInstallable = "github:limwa/nix-t3code/e024ef5edfa4cbff3fe681c18782029a5381637d#t3code-nightly";

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
    cloudflared
    zapzapWayland
    unstable.osu-lazer-bin
    unstable.google-cloud-sdk
  ];
}
