{ config, pkgs, ... }: 

{
  users.users.fjara = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "dialout" ];
    shell = pkgs.zsh;
    packages = [];
  };

  # Allow agents to activate this host's flake without an interactive password.
  security.sudo.extraRules = [
    {
      users = [ "fjara" ];
      runAs = "root";
      commands = [
        {
          # Escape the flake separator so sudoers does not treat it as a comment.
          command = "/run/current-system/sw/bin/nixos-rebuild switch --flake /home/fjara/dotfiles\\#${config.networking.hostName}";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  nix.settings.auto-optimise-store = true;
  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  time.timeZone = "America/Santiago";

  programs.nix-ld.enable = true;

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--ssh" ];
  };
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;
  networking.firewall = {
    enable = false;
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
  systemd.services.tailscaled.serviceConfig.Environment = [ 
    "TS_DEBUG_FIREWALL_MODE=nftables" 
  ];

  i18n.defaultLocale = "es_CL.UTF-8";
  i18n.extraLocaleSettings = {
    LC_MESSAGES = "en_US.UTF-8";
  };

  # Optimization: Prevent systemd from waiting for network online 
  # (Optional but recommended for faster boot with VPNs)
  systemd.network.wait-online.enable = false; 
  boot.initrd.systemd.network.wait-online.enable = false;

  programs.zsh.enable = true;
  programs.zsh.enableGlobalCompInit = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };
}
