# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, paths, ... }:
let
  unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.hostPlatform.system; config.allowUnfree = true; };

  # Hosts whose system closures are pre-built into huala's store so clients
  # can substitute them from the nix-serve cache instead of building.
  buildHosts = [ "yunco" "huala" "pudu" "fragata" ];
  flakePath = "/home/fjara/dotfiles";
in
{
  imports =
    [
      ./hardware-configuration.nix
      (paths.modules + "/system.nix")
      (paths.modules + "/desktop.nix")
    ];

  # For more information, see `man configuration.nix` 
  # or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05";

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

  # Keep routine boot messages hidden while still showing failures.
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "systemd.show_status=auto"
    "rd.systemd.show_status=auto"
  ];

  networking.hostName = "huala";

  # 12 cores; leave a few for whatever huala is doing itself.
  remoteBuilder.server.enable = true;

  # Nightly pre-build of every host's system closure so the nix-serve cache is
  # warm for clients. No flake update: build whatever the dotfiles currently pin.
  systemd.services.build-hosts = {
    description = "Pre-build all host system closures into the local cache";
    path = [ pkgs.nix ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      Nice = 10;
      IOSchedulingClass = "idle";
    };
    script = ''
      set -euo pipefail
      for host in ${builtins.concatStringsSep " " buildHosts}; do
        nix build --no-link \
          "${flakePath}#nixosConfigurations.$host.config.system.build.toplevel"
      done
    '';
  };

  systemd.timers.build-hosts = {
    description = "Nightly pre-build of all host system closures";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  users.users.progcomp = {
    isNormalUser = true;
    description = "Competitive programming";
  };

  home-manager.users.progcomp = import ./progcomp-home.nix;

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

  # t3code is configured per user via the home-manager module (home/t3code.nix);
  # the user services survive logout because of lingering.
  users.users.fjara.linger = true;

  users.users.ale = {
    isNormalUser = true;
    extraGroups = [];
    shell = pkgs.bash;
    packages = [];
    linger = true;
  };

  home-manager.users.ale = import ./ale-home.nix;
}
