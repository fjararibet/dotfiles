require('conform').setup {
  formatters_by_ft = {
    html = { 'djlint' },
    htmldjango = { 'djlint' },
    json = { 'prettier' },
    ocaml = { 'ocamlformat' },
  },
  formatters = {
    shfmt = { prepend_args = { '-i', '2' } },
  },
}

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
vim.keymap.set('', '<leader>f', function()
  require('conform').format { async = true, lsp_fallback = true }
end, { desc = 'Format buffer' })
