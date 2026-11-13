{ pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "loica";
  networking.localHostName = "loica";
  networking.computerName = "loica";

  system.primaryUser = "fjara";
  users.users.fjara.home = "/Users/fjara";

  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = 6;
}
