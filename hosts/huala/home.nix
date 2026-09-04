{ pkgs, paths, ... }:

{
  imports = [
    (paths.home + "/common.nix")
    (paths.home + "/desktop.nix")
  ];

  home.packages = with pkgs; [
    t3code
    zapzap
    unstable.osu-lazer-bin
    unstable.spotiflac
    unstable.google-cloud-sdk
  ];
}
