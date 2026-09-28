-- Set leaders before loading any plugin scripts.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Nix links the plugins into Neovim's native package directory. Load each
-- package now so its Lua modules and plugin scripts are available for setup.
local config_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')
vim.opt.runtimepath:prepend(config_dir)
vim.opt.packpath:prepend(config_dir)
for _, name in pairs(require 'config.nix-plugins') do
  vim.cmd.packadd(name)
end

require 'config.plugins.colorschemes'
vim.cmd.colorscheme 'kanagawa'

for _, name in ipairs {
  'cmp',
  'conform',
  'git',
  'init',
  'lsp',
  'lualine',
  'oil',
  'telescope',
  'treesitter',
  'undotree',
} do
  require('config.plugins.' .. name)
end
