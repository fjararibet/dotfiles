{ lib, pkgs, inputs, paths, ... }:


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
  systemd.user.services = {
    elephant.Install.WantedBy = lib.mkForce [ "sway-session.target" ];
    elephant.Service.Environment = [ "XDG_SESSION_TYPE=wayland" ];
    walker.Install.WantedBy = lib.mkForce [ "sway-session.target" ];
  };
  xdg.configFile.alacritty.source = paths.config + "/alacritty";
  xdg.configFile.sway.source = paths.config + "/sway";
  xdg.configFile.walker.source = paths.config + "/walker";
  xdg.configFile.waybar.source = paths.config + "/waybar";
  xdg.configFile.wlogout.source = paths.config + "/wlogout";
}
