{ lib, pkgs, inputs, paths, ... }:

let
  elephantPackages = inputs.elephant.packages.${pkgs.stdenv.hostPlatform.system};
  vendorHash = "sha256-5AL1731OKp2AZgknZAvcfyL+TuU3DIPozjSItE5nOM8=";
  elephant = elephantPackages.elephant.overrideAttrs { inherit vendorHash; };
  providers = elephantPackages.elephant-providers.overrideAttrs { inherit vendorHash; };
  kanagawa = (builtins.fromTOML (builtins.readFile (paths.config + "/alacritty/kanagawa.toml"))).colors;
  cssColor = color: builtins.replaceStrings [ "0x" ] [ "#" ] color;
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
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  home.packages = with pkgs; [
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
    playerctl
    vlc
    hledger
  ];

  programs.walker = {
    enable = true;
    runAsService = true;
    config = builtins.fromTOML (builtins.readFile (paths.config + "/walker/config.toml"));
    themes.default.style = builtins.readFile (paths.config + "/walker/themes/default/style.css");
  };
  programs.elephant.package = elephantPackages.elephant-with-providers.overrideAttrs {
    buildInputs = [ elephant providers ];
    installPhase = ''
      mkdir -p $out/bin $out/lib/elephant
      cp ${elephant}/bin/elephant $out/bin/
      cp -r ${providers}/lib/elephant/providers $out/lib/elephant/
    '';
  };
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  systemd.user.services = {
    elephant.Install.WantedBy = lib.mkForce [ "sway-session.target" "niri.service" ];
    elephant.Service.Environment = [ "XDG_SESSION_TYPE=wayland" ];
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
