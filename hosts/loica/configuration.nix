{ pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "loica";
  networking.localHostName = "loica";
  networking.computerName = "loica";

  system.primaryUser = "fjara";
  users.users.fjara.home = "/Users/fjara";

  security.sudo.extraConfig = ''
    fjara ALL=(root) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild switch --flake /Users/fjara/dotfiles\#loica
  '';

  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  nix-homebrew = {
    enable = true;
    user = "fjara";
  };

  homebrew = {
    enable = true;
    casks = [ "tunnelblick" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = 6;
}
