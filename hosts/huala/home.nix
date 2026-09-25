{ pkgs, paths, ... }:
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

  home.packages = with pkgs; [
    cloudflared
    zapzapWayland
    unstable.osu-lazer-bin
    unstable.google-cloud-sdk
  ];
}
