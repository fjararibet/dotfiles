{ config, lib, pkgs, inputs, paths, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      (paths.modules + "/system.nix")
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems.zfs = true;

  boot.zfs.extraPools = [ "zpool" ];
  networking.hostName = "pudu";
  networking.hostId = "41c929f8";
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
  ];

  # For more information, see `man configuration.nix` 
  # or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05";

}
