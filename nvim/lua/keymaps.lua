-- define common options
local opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
}

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)



-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- neo-tree
vim.keymap.set('n', 'fe', ':Neotree<CR>', opts)

-- telescope
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', opts)
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', opts)
vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>', opts)

-- LSP and Copilots
-- vim.keymap.set('n', '<leader>cc', ':Codeium Chat<CR>', opts)
-- vim.keymap.set('i', '<C-S-I>', ':Codeium Insert<CR>', opts)


-----------------
-- Insert mode --
-----------------
-- vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>i', opts)
-- vim.keymap.set('v', '<C-s>', '<Esc>:w<CR>', opts)
-- vim.keymap.set('n', '<C-s>', ':w<CR>', opts)
