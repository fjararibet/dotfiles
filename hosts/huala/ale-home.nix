{ pkgs, paths, ... }:

{
  imports = [
    (paths.home + "/t3code.nix")
  ];

  home.username = "ale";
  home.homeDirectory = "/home/ale";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    git
    nodejs_22
    texlive.combined.scheme-full
    python3
    unstable.opencode
  ];

  t3code.enable = true;
  t3code.profileManaged = true;
  t3code.profileInstallable = "github:limwa/nix-t3code/e024ef5edfa4cbff3fe681c18782029a5381637d#t3code-nightly";
  t3code.port = 3774;
}
