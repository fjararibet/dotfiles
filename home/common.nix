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
    unstable.opencode
    unstable.claude-code
  ];
  programs.zsh = {
    enable = true;
    envExtra = ''
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
      custom = toString (paths.config + "/zsh");
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

  xdg.configFile.clangd.source = paths.config + "/clangd";
  xdg.configFile.tmux.source = paths.config + "/tmux";
  xdg.configFile.git.source = paths.config + "/git";
}
