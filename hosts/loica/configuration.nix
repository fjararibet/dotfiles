{ pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "loica";
  networking.localHostName = "loica";
  networking.computerName = "loica";

  environment.etc."hosts" = {
    # Allow nix-darwin to back up and replace the standard macOS hosts file.
    knownSha256Hashes = [ "c7dd0e2ed261ce76d76f852596c5b54026b9a894fa481381ffd399b556c0e2da" ];
    text = ''
      127.0.0.1 localhost
      255.255.255.255 broadcasthost
      ::1 localhost

      # MUV infrastructure (reachable over VPN).
      10.10.10.11 esx01-stgo.muv.local
      10.10.10.12 esx02-stgo.muv.local
      10.10.10.10 vcsa-stgo.muv.local
      10.10.10.42 vproxy-stgo-01.muv.local
      10.10.10.43 vproxy-stgo-02.muv.local
    '';
  };

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
    masApps = {
      Amphetamine = 937984704;
    };
    # Keep unmanaged App Store apps when Homebrew runs bundle cleanup.
    onActivation.cleanup = "none";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = 6;
}
