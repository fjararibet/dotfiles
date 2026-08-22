{ pkgs, paths, ... }:

{
  imports = [
    (paths.home + "/common.nix")
    (paths.home + "/desktop.nix")
  ];

  home.packages = with pkgs; [
    cloudflared
    mdbtools
    playwright-mcp
    stow
    typescript-language-server
    unstable.bun
    unstable.nodejs
    unstable.opencode-desktop
    unstable.osu-lazer-bin
  ];
}
