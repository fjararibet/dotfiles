{ pkgs, paths, ... }:

{
  imports = [
    (paths.home + "/common.nix")
  ];
}
