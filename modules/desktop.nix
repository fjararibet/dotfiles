{ lib, pkgs, ... }:
{
  hardware.graphics.enable = true;

  # Required by OpenTabletDriver
  hardware.uinput.enable = true;
  hardware.opentabletdriver.enable = true;
  boot.kernelModules = [ "uinput" ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;
      package = pkgs.wireplumber;
    };
  };
  environment.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    EDITOR = "nvim";
  };

  xdg.icons.fallbackCursorThemes = [ "Adwaita" ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [ 
      commit-mono
      liberation_ttf
      nerd-fonts.symbols-only
    ];

    fontconfig = {
      defaultFonts = {
        serif = [  "Liberation Serif " ];
        sansSerif = [ "Liberation Sans" ];
        monospace = [ "CommitMono" ];
      };
    };
    fontDir.enable = true;
  };
  programs.firefox.enable = true;
  programs.dconf.enable = true;

  programs.niri.enable = true;
  programs.hyprlock.enable = true;
  # Niri starts this on demand to support X11 applications such as Steam.
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    awww
    wlogout
    waybar
    xwayland-satellite
  ];
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.ly.enableGnomeKeyring = true;
  xdg.portal = {
    enable = true;
    config = {
      common.default = [ "gtk" ];
      niri.default = [ "gnome" "gtk" ];
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };
  services.displayManager.ly = {
    enable = true;
    settings = {
      session_log = "null";
    };
  };
  programs.ssh.startAgent = true;
  services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
}
