{ inputs, pkgs, paths, ... }:

let
  nvimPkgs = import inputs.nixpkgs-neovim {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };

in
{
  programs.neovim = {
    enable = true;
    package = nvimPkgs.neovim-unwrapped;
    plugins = with nvimPkgs.vimPlugins; [
      vim-sleuth
      which-key-nvim
      vim-python-pep8-indent
      nvim-cmp
      luasnip
      cmp_luasnip
      cmp-path
      cmp-buffer
      cmp-nvim-lsp
      kanagawa-nvim
      oil-nvim
      nvim-web-devicons
      gitsigns-nvim
      diffview-nvim
      telescope-nvim
      plenary-nvim
      telescope-fzf-native-nvim
      lualine-nvim
      conform-nvim
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
    ];
    initLua = builtins.readFile (paths.config + "/nvim/init.lua");
  };

  home.packages = [ pkgs.go pkgs.gopls pkgs.nil pkgs.tree-sitter pkgs.vscode-langservers-extracted ];
  xdg.configFile = {
    "nvim/lua".source = paths.config + "/nvim/lua";
    "nvim/plugin".source = paths.config + "/nvim/plugin";
    "nvim/after".source = paths.config + "/nvim/after";
  };
}
