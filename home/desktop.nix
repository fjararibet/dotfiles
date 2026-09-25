{ lib, pkgs, inputs, paths, ... }:

let
  elephantPackages = inputs.elephant.packages.${pkgs.stdenv.hostPlatform.system};
  vendorHash = "sha256-5AL1731OKp2AZgknZAvcfyL+TuU3DIPozjSItE5nOM8=";
  elephant = elephantPackages.elephant.overrideAttrs { inherit vendorHash; };
  providers = elephantPackages.elephant-providers.overrideAttrs { inherit vendorHash; };
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
    gammastep
    discord
    vesktop
    obsidian
    spotify
    davinci-resolve
    paraview
    pavucontrol
    playerctl
    vlc
    rofi
    hledger
  ];

  programs.walker = {
    enable = true;
    runAsService = true;
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
  xdg.configFile."niri/waybar.jsonc".text = builtins.replaceStrings
    [
      "sway/workspaces"
      "\"disable-click\": true"
      "    \"disable-scroll\": true,\n"
      "    \"persistent-workspaces\": {\n      \"1\": [],\n      \"2\": [],\n      \"3\": [],\n      \"4\": [],\n    }\n"
    ]
    [ "niri/workspaces" "\"disable-click\": false" "" "" ]
    (builtins.readFile (paths.config + "/waybar/config.jsonc"));
  xdg.configFile.walker.source = paths.config + "/walker";
  xdg.configFile.waybar.source = paths.config + "/waybar";
  xdg.configFile.wlogout.source = paths.config + "/wlogout";
}
