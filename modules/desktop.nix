{ config, lib, pkgs, inputs, ... }:
let
  swayPkgs = inputs.nixpkgs-sway-working.legacyPackages.${pkgs.stdenv.hostPlatform.system};
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
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    EDITOR = "nvim";
  };

  # Ensure user services, including Discord launched by Walker, identify the
  # session as Wayland and enable PipeWire-based screen sharing.
  systemd.user.extraConfig = ''
    DefaultEnvironment="XDG_SESSION_TYPE=wayland" "XDG_SESSION_DESKTOP=sway"
  '';

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
    ];
  };
  programs.sway.xwayland.enable = true;
  xdg.portal = {
    enable = true;
    config = {
      common.default = [ "gtk" ];
      sway.default = lib.mkForce [ "wlr" "gtk" ];
    };
    wlr.settings.screencast = {
      chooser_type = "simple";
      chooser_cmd = ''${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or'';
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };
  services.displayManager.ly = {
    enable = true;
    settings = {
      session_log = "null";
    };
  };
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.ly.enableGnomeKeyring = true;

  # GCR provides the SSH agent used for Git SSH signing, but Sway does not
  # inherit the socket path from the systemd user manager.
  environment.extraInit = lib.mkIf config.services.gnome.gcr-ssh-agent.enable (lib.mkAfter ''
    if [ -z "$SSH_AUTH_SOCK" ] && [ -n "$XDG_RUNTIME_DIR" ]; then
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
    fi
  '');

  services.desktopManager.gnome.enable = true;
  services.gnome.games.enable = false;
  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];
}
