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
  boot.zfs.forceImportRoot = false;

  boot.zfs.extraPools = [ "zpool" ];

  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", \
      ATTR{queue/rotational}=="1", \
      RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S 241 /dev/%k"
  '';

  networking.hostName = "pudu";
  networking.hostId = "41c929f8";
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
  ];

  t3code.enable = true;
  remoteBuilder.client.enable = true;

  # For more information, see `man configuration.nix` 
  # or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05";

}
