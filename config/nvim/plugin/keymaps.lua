vim.keymap.set('n', '<C-b>', '')
vim.keymap.set('n', '<C-f>', '')
-- vim.keymap.set('n', '<leader>e', '<cmd>Explore<CR>', { desc = ' [E]xplore files', silent = true })
vim.keymap.set('n', '<leader>e', '<cmd>Oil<CR>', { desc = ' [E]xplore files', silent = true })

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- custom: Probably should be in a nother file
vim.keymap.set('n', "<C-u>", "<C-u>zz")
vim.keymap.set('n', "<C-d>", "<C-d>zz")
vim.keymap.set('v', "J", ":m '>+1<CR>gv=gv")
vim.keymap.set('v', "K", ":m '<-2<CR>gv=gv")
vim.keymap.set('n', '<leader>x', "<cmd>!chmod +x %<CR>", { silent = true, desc = 'Make file e[x]ecutable' })
vim.api.nvim_create_user_command('W', 'w', { nargs = 0 })
vim.api.nvim_create_user_command('Wq', 'wq', { nargs = 0 })
vim.api.nvim_create_user_command('WQ', 'wq', { nargs = 0 })
vim.api.nvim_create_user_command('Q', 'q', { nargs = 0 })


