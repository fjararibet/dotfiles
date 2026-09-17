{ pkgs, paths, ... }:

{
  imports = [
    (paths.home + "/common.nix")
    (paths.home + "/desktop.nix")
    (paths.home + "/t3code.nix")
  ];

  t3code.enable = true;

  home.packages = with pkgs; [
    zapzap
    unstable.osu-lazer-bin
    unstable.spotiflac
    unstable.google-cloud-sdk
  ];
}
