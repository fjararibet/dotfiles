{ config, lib, pkgs, paths, ... }:

let
  kanagawa = (builtins.fromTOML (builtins.readFile (paths.config + "/alacritty/kanagawa.toml"))).colors;
  cssColor = color: builtins.replaceStrings [ "0x" ] [ "#" ] color;
  displayMenu = pkgs.writeShellApplication {
    name = "niri-display-menu";
    runtimeInputs = [ pkgs.niri pkgs.jq pkgs.libnotify config.programs.walker.package ];
    text = builtins.readFile (paths.config + "/niri/display-menu.sh");
  };
  wlogoutIcons = pkgs.runCommand "wlogout-kanagawa-icons" {
    nativeBuildInputs = [ pkgs.imagemagick ];
  } ''
    mkdir -p "$out"
    for icon in ${pkgs.wlogout}/share/wlogout/icons/*.png; do
      magick "$icon" -channel RGB -fill '${cssColor kanagawa.primary.foreground}' -colorize 100 +channel "$out/$(basename "$icon")"
    done
  '';
in
{
  home.packages = with pkgs; [
    displayMenu
    qbittorrent
    audacious
    alacritty
    obs-studio
    audacity
    discord
    ferdium
    vesktop
    obsidian
    spotify
    davinci-resolve
    paraview
    pavucontrol
    networkmanagerapplet
    playerctl
    vlc
    hledger
  ];

  services.network-manager-applet.enable = true;
  xsession.preferStatusNotifierItems = true;

  services.walker = {
    enable = true;
    package = pkgs.unstable.walker;
    systemd.enable = true;
    enableElephantIntegration = true;
    settings = builtins.fromTOML (builtins.readFile (paths.config + "/walker/config.toml"));
    theme = {
      name = "default";
      style = builtins.readFile (paths.config + "/walker/themes/default/style.css");
    };
  };
  services.elephant = {
    enable = true;
    package = pkgs.unstable.elephant;
  };
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Adwaita-dark";
  };
  systemd.user.services = {
    # Keep both backends tied to the active Wayland session, as with the
    # upstream modules. Nixpkgs' Elephant wrapper discovers its own providers.
    elephant.Unit = {
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    elephant.Install.WantedBy = lib.mkForce [ "sway-session.target" "niri.service" ];
    elephant.Service.Environment = [ "XDG_SESSION_TYPE=wayland" ];
    walker.Unit = {
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    walker.Install.WantedBy = lib.mkForce [ "sway-session.target" "niri.service" ];
  };
  xdg.configFile.alacritty.source = paths.config + "/alacritty";
  xdg.configFile.sway.source = paths.config + "/sway";
  xdg.configFile."niri/config.kdl".source = paths.config + "/niri/config.kdl";
  xdg.configFile."niri/waybar.jsonc".source = paths.config + "/niri/waybar.jsonc";
  xdg.configFile.waybar.source = paths.config + "/waybar";
  xdg.configFile."kanagawa.css".text = ''
    /* Shared palette from alacritty/kanagawa.toml. */
    @define-color background ${cssColor kanagawa.primary.background};
    @define-color foreground ${cssColor kanagawa.primary.foreground};
    @define-color secondary ${cssColor kanagawa.normal.white};
    @define-color hover_background #363646;
    @define-color hover_foreground ${cssColor kanagawa.selection.foreground};
    @define-color accent ${cssColor kanagawa.normal.blue};
    @define-color success ${cssColor kanagawa.bright.green};
    @define-color warning ${cssColor kanagawa.normal.red};
    @define-color muted ${cssColor kanagawa.bright.black};
    @define-color bluetooth_enabled ${cssColor kanagawa.bright.blue};
    @define-color tooltip_foreground ${cssColor kanagawa.primary.foreground};
    @define-color tooltip_border alpha(${cssColor kanagawa.normal.white}, 0.2);
    @define-color shadow ${cssColor kanagawa.normal.black};
  '';
  xdg.configFile."wlogout/layout".source = paths.config + "/wlogout/layout";
  xdg.configFile."wlogout/style.css".text = builtins.replaceStrings
    [ "@WLOGOUT@" "@WLOGOUT_ICONS@" ]
    [ "${pkgs.wlogout}" "${wlogoutIcons}" ]
    (builtins.readFile (paths.config + "/wlogout/style.css"));
}
