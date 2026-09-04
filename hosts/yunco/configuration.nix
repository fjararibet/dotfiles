# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, paths, ... }:
{
  imports =
    [
      (paths.modules + "/system.nix")
    ];
  services.resolved = {
	  enable = true;
	  settings.Resolve.DNSSEC = "false";
	  settings.Resolve.Domains = [ "Dimacofi.cl" ];
  };
  services.openssh.enable = true;
  systemd.services.tailscaled.after = [ "systemd-resolved.service" ];
  systemd.services.tailscaled.wants = [ "systemd-resolved.service" ];

  # Upstream = WSL's DNS proxy (which proxies to Windows / corporate DNS)
  networking.hostName = "yunco";
  networking.nameservers = [ "10.255.255.254" ];
  networking.firewall.enable = false;

  # WSL manages networking itself
  networking.networkmanager.enable = lib.mkForce false;

  # fixes opencode/claude freezes
  services.timesyncd.enable = false;

  virtualisation.docker = {
    enable = true;
  };
  users.users.fjara = {
      uid = 1002;
      extraGroups = [ "wheel" "docker" "dialout" ];
      # `t3 service install` runs `loginctl enable-linger` as one of its steps.
      # Without it the t3code user unit only lives as long as a login session,
      # so the server would die with the last shell instead of staying up.
      linger = true;
  };
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    kmod
  ];

  wsl.enable = true;
  wsl.defaultUser = "fjara";
  wsl.wslConf.network.generateResolvConf = false;
  wsl.wslConf.network.hostname = "yunco";

  # No Windows interop at all: no /mnt/c mounts, no running .exe, no inherited
  # Windows PATH. Port forwarding (localhost:PORT from Windows) is unaffected --
  # that's WSL networking, configured in .wslconfig on the Windows side.
  wsl.wslConf.automount.enabled = false;
  wsl.wslConf.interop.enabled = false;
  wsl.wslConf.interop.appendWindowsPath = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
