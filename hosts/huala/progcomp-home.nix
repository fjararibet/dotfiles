{ pkgs, paths, ... }:

{
  home.username = "progcomp";
  home.homeDirectory = "/home/progcomp";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    firefox
    gcc
    gdb
    python3
    tmux
    vim
  ];

  home.file.".vimrc".source = paths.config + "/vim/vimrc";
}
