-- define common options
local opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
}


-- Scroll over wrapped lines
vim.keymap.set({"n", "v", "x"}, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({"n", "v", "x"}, "<Up>",   "v:count == 0 ? 'gk'   : 'k'",   { expr = true, silent = true })
vim.keymap.set("i", "<Up>",   "<C-o>gk", { silent = true })
vim.keymap.set("i", "<Down>", "<C-o>gj", { silent = true })

-- Alt/opt + arrows
vim.keymap.set({"n", "v", "i"}, "<M-f>", "<S-Right>", { silent = true })
vim.keymap.set({"n", "v", "i"}, "<M-b>", "<S-Left>", { silent = true })
vim.keymap.set({"n", "v", "i"}, "<M-Right>", "<S-Right>", { silent = true })
vim.keymap.set({"n", "v", "i"}, "<M-Left>", "<S-Left>", { silent = true })
vim.keymap.set({"n", "v", "i"}, "<M-Down>", "<Down>", { silent = true })
vim.keymap.set({"n", "v", "i"}, "<M-Up>", "<Up>", { silent = true })

-- Ctrl + arrows
-- insert mode is used for ai autocomplete
vim.keymap.set({"n", "v"}, "<C-Left>", "<Home>", { silent = true })
vim.keymap.set({"n", "v"}, "<C-Right>", "<End>", { silent = true })
vim.keymap.set({"n", "v"}, "<C-Up>", "<PageUp>", { silent = true })
vim.keymap.set({"n", "v"}, "<C-Down>", "<PageDown>", { silent = true })

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)
vim.api.nvim_exec([[
  autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>
]], false)

-- neo-tree
vim.keymap.set('n', 'fe', ':Neotree<CR>', opts)

-- telescope
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', opts)
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', opts)
vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>', opts)

-- Strip whitespace
local function strip_whitespace()
    local save_cursor = vim.fn.getpos(".")
    local old_query = vim.fn.getreg('/')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
    vim.fn.setreg('/', old_query)
end

vim.keymap.set("n", "<leader>ss", strip_whitespace, { desc = "Strip trailing whitespace" })

-- Save as root
vim.keymap.set("n", "<leader>W", ":w !sudo tee % > /dev/null<CR>", { silent = true })

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)


-- LSP and Copilots
-- vim.keymap.set('n', '<leader>cc', ':Codeium Chat<CR>', opts)
-- vim.keymap.set('i', '<C-S-I>', ':Codeium Insert<CR>', opts)


-----------------
-- Insert mode --
-----------------
-- vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>i', opts)
-- vim.keymap.set('v', '<C-s>', '<Esc>:w<CR>', opts)
-- vim.keymap.set('n', '<C-s>', ':w<CR>', opts)
--


-------------------
-- Miscellaneous --
-------------------

-- Tab indentation (Visual and Normal)
vim.keymap.set("n", "<tab>", "v> ", { noremap = true })
vim.keymap.set("n", "<s-tab>", "v< ", { noremap = true })
vim.keymap.set("v", "<tab>", ">gv", { noremap = true })
vim.keymap.set("v", "<s-tab>", "<gv", { noremap = true })

-- Comment out lines
vim.keymap.set("n", "<C-/>", function()
    require("Comment.api").toggle.linewise.current()
end, { desc = "Comment line" })
vim.keymap.set("v", "<C-/>", "<ESC><cmd>lua require('Comment.api').locked('toggle.linewise')(vim.fn.visualmode())<CR>gv", { desc = "Comment selection" })
vim.keymap.set("i", "<C-/>", function()
    require("Comment.api").toggle.linewise.current()
    vim.cmd("startinsert")
end, { desc = "Comment line" })

-- Save
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("v", "<C-s>", "<cmd>w<CR>gv", { desc = "Save file and keep selection" })
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>gi", { desc = "Save file and stay in insert" })
