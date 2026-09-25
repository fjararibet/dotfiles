{ config, lib, pkgs, inputs, ... }:
let
  swayPkgs = inputs.nixpkgs-sway-working.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  lySessionWrapper = pkgs.writeShellScript "ly-session-wrapper" ''
    case "$*" in
      *sway*)
        export XDG_CURRENT_DESKTOP=sway
        export XDG_SESSION_DESKTOP=sway
        ;;
    esac

    exec ${config.services.displayManager.sessionData.wrapper} "$@"
  '';
in {
  # Sway 1.11 retains the gamma-control protocol used by gammastep.
  nixpkgs.overlays = [
    (_final: _prev: {
      sway = swayPkgs.sway;
      sway-unwrapped = swayPkgs.sway-unwrapped;
    })
  ];

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

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      adwaita-icon-theme
      slurp
      sway-contrib.grimshot
      swayr
      wlogout
      waybar
      swaybg
      swaylock
    ];
  };
  programs.sway.xwayland.enable = true;
  programs.niri.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.ly.enableGnomeKeyring = true;
  xdg.portal = {
    enable = true;
    config = {
      common.default = [ "gtk" ];
      sway.default = lib.mkForce [ "wlr" "gtk" ];
      niri.default = [ "gnome" "gtk" ];
    };
    wlr.settings.screencast = {
      chooser_type = "simple";
      chooser_cmd = ''${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or'';
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gnome
    ];
  };
  services.displayManager.ly = {
    enable = true;
    settings = {
      session_log = "null";
      setup_cmd = "${lySessionWrapper}";
    };
  };
  programs.ssh.startAgent = true;
  services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
}
