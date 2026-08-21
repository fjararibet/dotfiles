{ config, pkgs, paths, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      (paths.modules + "/system.nix")
      (paths.modules + "/desktop.nix")
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "fragata";
  services.xserver.videoDrivers = [ "nvidia" "modesetting" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  users.users.fjara.extraGroups = [ "networkmanager" ];

  # Needed for Sway on this laptop's NVIDIA GPU.
  programs.sway = {
    extraOptions = [ "--unsupported-gpu" ];
    extraPackages = with pkgs; [
      bibata-cursors
      brightnessctl
      dmenu
      foot
      grim
      pulseaudio
      swayidle
      swaylock
      wmenu
      wofi
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
  ];

  services.libinput.enable = true;

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11";
}
