do
      local ts = require('nvim-treesitter')

      -- Nix provides all parsers in the plugin runtime path.

      -- The `main` branch no longer auto-enables highlighting; start it
      -- per-buffer on FileType. Skip dockerfile (matches the old config) and
      -- pcall so filetypes without an installed parser just no-op.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('my.treesitter.highlight', {}),
        callback = function(args)
          if vim.bo[args.buf].filetype == 'dockerfile' then
            return
          end
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      -- [[ Textobjects ]]
      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true, -- jump forward to the textobj, like targets.vim
        },
        move = {
          set_jumps = true, -- store moves in the jumplist
        },
      }

      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')
      local swap = require('nvim-treesitter-textobjects.swap')

      -- select (operator-pending + visual)
      local selections = {
        aa = '@parameter.outer',
        ia = '@parameter.inner',
        af = '@function.outer',
        ['if'] = '@function.inner',
        ac = '@class.outer',
        ic = '@class.inner',
      }
      for lhs, query in pairs(selections) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(query, 'textobjects')
        end, { desc = 'Select ' .. query })
      end

      -- move
      vim.keymap.set({ 'n', 'x', 'o' }, ']m', function() move.goto_next_start('@function.outer', 'textobjects') end, { desc = 'Next function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() move.goto_next_start('@class.outer', 'textobjects') end, { desc = 'Next class start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']M', function() move.goto_next_end('@function.outer', 'textobjects') end, { desc = 'Next function end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '][', function() move.goto_next_end('@class.outer', 'textobjects') end, { desc = 'Next class end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[m', function() move.goto_previous_start('@function.outer', 'textobjects') end, { desc = 'Previous function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() move.goto_previous_start('@class.outer', 'textobjects') end, { desc = 'Previous class start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[M', function() move.goto_previous_end('@function.outer', 'textobjects') end, { desc = 'Previous function end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[]', function() move.goto_previous_end('@class.outer', 'textobjects') end, { desc = 'Previous class end' })

      -- swap
      vim.keymap.set('n', '<leader>a', function() swap.swap_next('@parameter.inner') end, { desc = 'Swap parameter next' })
      vim.keymap.set('n', '<leader>A', function() swap.swap_previous('@parameter.inner') end, { desc = 'Swap parameter previous' })
end
