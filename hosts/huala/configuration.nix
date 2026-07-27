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

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
    grub.enable = true;
    grub.device = "nodev";
    grub.useOSProber = true;
    grub.efiSupport = true;
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

  # For more information, see `man configuration.nix` 
  # or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05";

}
