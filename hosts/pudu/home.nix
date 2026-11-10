{ pkgs, paths, ... }:

{
  imports = [
    (paths.home + "/common.nix")
  ];

  programs.t3code = {
    enable = true;
    package = pkgs.unstable.t3code;
  };
}
