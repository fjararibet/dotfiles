{ config, lib, pkgs, paths, ... }:

let
  kanagawa = (builtins.fromTOML (builtins.readFile (paths.config + "/alacritty/kanagawa.toml"))).colors;
  cssColor = color: builtins.replaceStrings [ "0x" ] [ "#" ] color;
  displayMenu = pkgs.writeShellApplication {
    name = "niri-display-menu";
    runtimeInputs = [ pkgs.niri pkgs.jq pkgs.libnotify config.services.walker.package ];
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
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/ferdium" = [ "ferdium.desktop" ];
      "x-scheme-handler/discord" = [ "vesktop.desktop" ];
      "x-scheme-handler/discord-1216669957799018608" = [ "discord-1216669957799018608.desktop" ];
      "x-scheme-handler/claude-cli" = [ "claude-code-url-handler.desktop" ];
      "x-scheme-handler/t3code" = [ "com.t3tools.T3Code.desktop" ];
      "x-scheme-handler/codex" = [ "chatgpt.desktop" ];
    };
    associations.added."x-scheme-handler/ferdium" = [ "ferdium.desktop" ];
  };

  home.sessionVariables.BROWSER = "firefox";

  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;

  home.packages = with pkgs; [
    displayMenu
    audacious
    alacritty
    ferdium
    vesktop
    obsidian
    spotify
    pavucontrol
    networkmanagerapplet
    playerctl
    vlc
    unstable.chatgpt
  ];

  services.network-manager-applet.enable = true;
  xsession.preferStatusNotifierItems = true;

  programs.hyprlock = {
    enable = true;
    settings = {
      animations.enabled = false;
      background = [{
        monitor = "";
        path = "${../wallpapers/teatime.jpg}";
        # More passes and a larger size produce stronger blur; 0 passes disables it.
        blur_passes = 2;
        blur_size = 2;
      }];
      input-field = [{
        monitor = "";
        size = "300, 56";
        position = "0, -100";
        halign = "center";
        valign = "center";
        outline_thickness = 0;
        inner_color = "rgba(0, 0, 0, 0)";
        font_color = "rgb(${lib.removePrefix "0x" kanagawa.primary.foreground})";
        # Apply authentication colors to the dots, not the transparent background.
        swap_font_color = true;
        check_color = "rgb(${lib.removePrefix "0x" kanagawa.bright.green})";
        fail_color = "rgb(${lib.removePrefix "0x" kanagawa.normal.red})";
        placeholder_text = "";
        fail_text = "authentication failed";
      }];
      label = [{
        monitor = "";
        text = "$TIME";
        font_size = 64;
        color = "rgb(${lib.removePrefix "0x" kanagawa.primary.foreground})";
        position = "0, 50";
        halign = "center";
        valign = "center";
      }];
    };
  };

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
  xdg.configFile."kanagawa.css".source = paths.config + "/kanagawa.css";
  xdg.configFile."wlogout/layout".source = paths.config + "/wlogout/layout";
  xdg.configFile."wlogout/style.css".source = paths.config + "/wlogout/style.css";
  xdg.configFile."wlogout/default.css".source = "${pkgs.wlogout}/etc/wlogout/style.css";
  xdg.configFile."wlogout/icons".source = wlogoutIcons;
}
