-- Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local plugins = require 'config.nix-plugins'

-- Lazy loads plugin definitions, while Nix provides their immutable sources.
vim.opt.rtp:prepend(plugins['folke/lazy.nvim'])

local function is_plugin(spec)
  return type(spec) == 'table' and type(spec[1]) == 'string'
end

local function use_nix_store(spec)
  if type(spec) == 'string' then
    spec = { spec }
  end

  if is_plugin(spec) then
    local repo = spec[1]
    spec.dir = assert(plugins[repo], ('Nix has no source for %s'):format(repo))
    spec.dependencies = vim.tbl_map(use_nix_store, spec.dependencies or {})
    return spec
  end

  return vim.tbl_map(use_nix_store, spec)
end

local specs = {}
for _, name in ipairs {
  'colorschemes',
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
  local spec = use_nix_store(require('config.plugins.' .. name))
  if is_plugin(spec) then
    table.insert(specs, spec)
  else
    vim.list_extend(specs, spec)
  end
end

require('lazy').setup(specs)

vim.cmd.colorscheme 'kanagawa'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
