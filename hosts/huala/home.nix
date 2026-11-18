{ config, inputs, pkgs, paths, ... }:
let
  profileBin = "${config.home.homeDirectory}/.nix-profile/bin";
  zapzapWayland = pkgs.symlinkJoin {
    name = "zapzap-wayland";
    paths = [ pkgs.zapzap ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/zapzap --set QT_QPA_PLATFORM wayland
    '';
  };
in {
  disabledModules = [ "${inputs.home-manager}/modules/programs/t3code.nix" ];
  imports = [
    inputs.home-manager-t3code.outPath
    (paths.home + "/common.nix")
    (paths.home + "/desktop.nix")
  ];

  # Keep T3 Code independently updatable through fjara's Nix profile.
  programs.t3code = {
    enable = true;
    package = pkgs.writeShellScriptBin "t3" ''
      exec "${profileBin}/t3" "$@"
    '';
    server.enable = true;
  };

  xdg.desktopEntries."com.t3tools.T3Code" = {
    name = "T3 Code (Alpha)";
    comment = "Minimal web GUI for coding agents";
    exec = "${profileBin}/t3code-desktop %U";
    icon = "t3code";
    terminal = false;
    categories = [ "Development" ];
    mimeType = [ "x-scheme-handler/t3code" ];
    settings.StartupWMClass = "t3code";
  };

  # Keep profile-installed provider CLIs available to the upstream unit.
  systemd.user.services.t3code.Service = {
    WorkingDirectory = "%h";
    Environment = [
      "PATH=${profileBin}:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin"
    ];
  };

  home.packages = with pkgs; [
    qbittorrent
    cloudflared
    zapzapWayland
    unstable.osu-lazer-bin
    unstable.google-cloud-sdk
  ];
}
