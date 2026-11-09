-- Set leaders before loading any plugin scripts.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Load Home Manager's native packages before configuring their plugin scripts.
vim.cmd.packloadall()

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
} do
  require('config.plugins.' .. name)
end
