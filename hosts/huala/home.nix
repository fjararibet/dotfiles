{ pkgs, paths, ... }:

{
  imports = [
    (paths.home + "/common.nix")
    (paths.home + "/desktop.nix")
    (paths.home + "/t3code.nix")
  ];

  t3code.enable = true;

  home.packages = with pkgs; [
    cloudflared
    zapzap
    unstable.osu-lazer-bin
    unstable.google-cloud-sdk
  ];
}
