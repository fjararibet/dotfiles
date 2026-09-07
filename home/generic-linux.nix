{
  config,
  lib,
  pkgs,
  ...
}:

# Standalone Home Manager on a machine we do not own root on.
#
{
  targets.genericLinux.enable = true;

  # Without root we cannot chsh, so login leaves SHELL pointing at the passwd
  # shell. tmux picks default-shell from SHELL first, then getpwuid, so new
  # panes would come up as login bash. Anything else reading SHELL — editors
  # opening a terminal, `git`'s pager setup — was getting bash too.
  home.sessionVariables.SHELL = "${config.programs.zsh.package}/bin/zsh";

  # The first build still needs --extra-experimental-features on the command
  # line; this keeps it enabled for every invocation after that. Written
  # directly rather than via nix.settings, which would pull a second Nix into
  # the profile and risk clashing with a root-managed daemon.
  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  # Emit the managed ~/.profile for shells started after manual activation.
  programs.bash.enable = true;

  # The launcher/session manager may replace PATH after hm-session-vars.sh has
  # been sourced. Its exported guard is inherited by new tmux panes, so restore
  # the Home Manager profile in every zsh. Nix itself is not installed in that
  # profile, so also expose the exact Nix used by Home Manager.
  programs.zsh.envExtra = lib.mkAfter ''
    typeset -U path
    path=("$HOME/.nix-profile/bin" "${pkgs.nix}/bin" $path)
    export PATH
    export SHELL="${config.programs.zsh.package}/bin/zsh"
  '';

  # logind starts the systemd user manager before our bootstrap runs, so it
  # derives its unit search path from the passwd home and never sees the units
  # written here. Atuin works fine without the daemon; it is a latency
  # optimisation. daemon-fuzzy requires it, so drop back to plain fuzzy.
  programs.atuin = {
    daemon.enable = lib.mkForce false;
    settings = {
      daemon.enabled = lib.mkForce false;
      search_mode = lib.mkForce "fuzzy";
    };
  };
}
