return {
  {
    -- Adds git releated signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gbl', require('gitsigns').blame_line, { buffer = bufnr, desc = '[G]it [B]lame [L]ine' })
        vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk, { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
        vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
        vim.keymap.set('n', '<leader>gp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[G]it [P]review Hunk' })
        vim.keymap.set('n', '<leader>grh', require('gitsigns').reset_hunk, { buffer = bufnr, desc = '[Git] [R]estore [H]unk' })
        vim.keymap.set('n', '<leader>gsh', require('gitsigns').stage_hunk, { buffer = bufnr, desc = '[G]it [S]tage [H]unk' })
        vim.keymap.set('n', '<leader>guh', require('gitsigns').undo_stage_hunk, { buffer = bufnr, desc = '[G]it [U]ndo Stage [H]unk' })
      end,
    },
  },

  {
    -- Single tabpage interface for cycling through git diffs and file history
    'sindrets/diffview.nvim',
  },
}
