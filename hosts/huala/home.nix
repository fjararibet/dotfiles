{ pkgs, paths, ... }:

{
  imports = [
    (paths.home + "/common.nix")
    (paths.home + "/desktop.nix")
  ];

  home.packages = with pkgs; [
    zapzap
    unstable.t3code
    unstable.osu-lazer-bin
    unstable.spotiflac
    unstable.google-cloud-sdk
  ];
}
