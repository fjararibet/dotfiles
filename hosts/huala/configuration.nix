# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, paths, ... }:
let
  unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.hostPlatform.system; config.allowUnfree = true; };
in
{
  imports =
    [
      ./hardware-configuration.nix
      (paths.modules + "/system.nix")
      (paths.modules + "/desktop.nix")
    ];

  services.plex = {
    enable = true;
    openFirewall = true;
  };

  # Boot NixOS directly; hold Space during startup to open the boot menu.
  boot.loader = {
    systemd-boot.enable = true;
    timeout = 0;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
  };

  networking.hostName = "huala";

  programs.steam = {
    enable = true;
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
  ];

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "fjara" ];

  # For more information, see `man configuration.nix` 
  # or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05";

}
