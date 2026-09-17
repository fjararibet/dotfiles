{ pkgs, paths, ... }:

{
  imports = [
    (paths.home + "/common.nix")
    (paths.home + "/t3code.nix")
  ];

  t3code.enable = true;
}
