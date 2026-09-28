do
      require('html-css').setup {}
      vim.opt.completeopt = { "menu", "menuone", "noselect" }
      -- [[ Configure nvim-cmp ]]
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      require('luasnip.loaders.from_vscode').lazy_load()
      luasnip.config.setup {}
      luasnip.filetype_extend("htmldjango", { "html" })
      luasnip.filetype_extend("javascriptreact", { "html" })

      -- [[ Custom snippets ]]
      local s = luasnip.snippet
      local t = luasnip.text_node

      luasnip.add_snippets("cpp", {
        s('comp', {
          t('#include <bits/stdc++.h>'),
          t({ '', 'using namespace std;' }),
          t({ '', 'void solve() {' }),
          t({ '', '}' }),
          t({ '', 'int main() {' }),
          t({ '', '  ios::sync_with_stdio(0);' }),
          t({ '', '  cin.tie(0);' }),
          t({ '', '  int t;' }),
          t({ '', '  t = 1;' }),
          t({ '', '  // cin >> t;' }),
          t({ '', '  while (t--)' }),
          t({ '', '    solve();' }),
          t(''),
          t({ '', '}' }),
        })
      })

      ---@diagnostic disable-next-line: missing-fields
      cmp.setup {
        completion = {
          autocomplete = false, -- Disable automatic completion
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-u>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<C-y>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'html-css' },
          { name = 'path' },
          { name = 'buffer' },
        },
      }
end
