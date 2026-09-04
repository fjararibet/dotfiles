{ pkgs, paths, ... }:

{
  imports = [ (paths.home + "/neovim.nix") ];

  home.username = "fjara";
  home.homeDirectory = "/home/fjara";
  programs.home-manager.enable = true;
  home.stateVersion = "26.05";
  home.packages = with pkgs; [
    uv
    jq
    fd
    git
    nil
    zip
    tree
    tree
    lsof
    ttyp
    htop
    clang
    unzip
    delta
    ripgrep
    tree-sitter
    wl-clipboard
    vim-full
    unstable.tmux
    unstable.codex
    unstable.t3code
    unstable.opencode
    unstable.github-cli
    unstable.claude-code
    unstable.pi-coding-agent
  ];
  programs.zsh = {
    enable = true;
    envExtra = ''
      # On the generic-linux host, the launcher/session manager may replace
      # PATH after hm-session-vars.sh has been sourced.  Its exported guard is
      # inherited by new tmux panes, so they otherwise skip restoring the Home
      # Manager profile.  Keep the essential profile path idempotently present
      # in every zsh, including non-login shells.
      typeset -U path
      path=("$HOME/.nix-profile/bin" $path)
      export PATH
      export SHELL="$HOME/.nix-profile/bin/zsh"

      ZSH_DISABLE_COMPFIX="true"
      if [[ -o interactive ]]; then
        alias compinit='compinit -C'
      fi
    '';
    initContent = builtins.readFile (paths.config + "/zsh/dot-zshrc.zsh");
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "theme";
      # Interpolate rather than toString: toString yields the path as a bare
      # string with no build input declared, so Nix registers no reference and
      # nothing keeps the themes alive across a garbage collect.
      custom = "${paths.config + "/zsh"}";
    };
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    forceOverwriteSettings = true;
    daemon.enable = true;

    flags = [
      "--disable-up-arrow"
    ];

    settings = {
      daemon.enabled = true;
      daemon.autostart = true;
      search_mode = "daemon-fuzzy";
      enter_accept = true;
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.file.".vimrc".source = paths.config + "/vim/vimrc";

  xdg.configFile.clangd.source = paths.config + "/clangd";
  xdg.configFile.tmux.source = paths.config + "/tmux";
  xdg.configFile.git.source = paths.config + "/git";
  xdg.configFile.vim.source = paths.config + "/vim";
}
