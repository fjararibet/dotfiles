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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # Keep external displays running when the laptop lid is closed.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
  services.xserver.videoDrivers = [ "nvidia" "modesetting" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    # Pascal (GTX 1050) requires the 580 legacy driver; newer branches drop support.
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
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

  services.openssh.extraConfig = ''
    Match User irenko
      AuthenticationMethods publickey
      PubkeyAuthentication yes
      PasswordAuthentication no
      KbdInteractiveAuthentication no
    Match all
  '';

  users.users.irenko = {
    isNormalUser = true;
    description = "Irenko";
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILh0z2coU+js/lOWfvO2skzf4azGGLx656iiQqhzAQX5 irenko-mac"
    ];
    packages = with pkgs; [
      unstable.codex
      git
      curl
      wget
      openssh
      tmux
      vim
      ripgrep
      fd
      jq
      unzip
      zip
      gnumake
      gcc
      pkg-config
      python3
      nodejs
    ];
  };

  # gcr-ssh-agent 4.4.0.1 loops in ssh-add when loading an ED25519 key.
  # Keep GNOME Keyring for secrets, but use OpenSSH's agent on this host.
  services.gnome.gcr-ssh-agent.enable = false;
  programs.ssh.startAgent = true;

  # Needed for Sway on this laptop's NVIDIA GPU.
  programs.sway = {
    extraOptions = [ "--unsupported-gpu" ];
    extraPackages = with pkgs; [
      bibata-cursors
      brightnessctl
      dmenu
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
