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
-- C-Up/C-Down reserved for Codeium AI navigation

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)
-- Configure img-paste.vim before the autocmd
vim.g.mdip_imgdir = '.attachments'
vim.g.mdip_imgname = 'img'

vim.api.nvim_exec([[
  autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>
]], false)

-- Open image under cursor in external viewer
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "quarto" },
    callback = function()
        vim.keymap.set("n", "gx", function()
            -- Get the word under cursor (image path)
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            -- Match markdown image: ![alt](...) or just file path
            local path = line:match("!%[.-%]%((.-)%)")
            if not path then
                -- Try to get word under cursor as fallback
                path = vim.fn.expand("<cfile>")
            end

            if path and path ~= "" then
                -- Handle relative paths
                if not path:match("^/") and not path:match("^%w+://") then
                    local current_file = vim.fn.expand("%:p:h")
                    path = current_file .. "/" .. path
                end

                -- Open with system default viewer
                local cmd
                if vim.fn.has("mac") == 1 then
                    cmd = "open"
                elseif vim.fn.has("unix") == 1 then
                    cmd = "xdg-open"
                elseif vim.fn.has("win32") == 1 then
                    cmd = "start"
                end

                if cmd then
                    vim.fn.jobstart({cmd, path}, {detach = true})
                end
            end
        end, { buffer = true, desc = "Open image under cursor" })
    end,
})


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

-- Tab is reserved for completion navigation in insert mode
-- Use >> and << in normal mode, > and < in visual mode for indentation

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

-- Dismiss notifications
vim.keymap.set("n", "<leader>nd", function()
    require("notify").dismiss({ silent = true, pending = true })
end, { desc = "Dismiss all notifications" })

-- Jupyter/Quarto cell execution (molten-nvim)
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python", "julia", "r", "quarto", "markdown" },
    callback = function()
        -- Activate quarto for this buffer (enables cell recognition)
        pcall(function()
            require("quarto").activate()
        end)

        -- Initialize molten for the buffer (smart venv detection)
        vim.keymap.set("n", "<leader>mi", function()
            require("jupyter-venv").init_molten()
        end, { buffer = true, desc = "Initialize Molten (smart venv)", silent = true })

        -- Check current environment
        vim.keymap.set("n", "<leader>me", function()
            require("jupyter-venv").check_environment()
        end, { buffer = true, desc = "Check Python environment", silent = true })

        -- Cell execution (with proper # %% support for Python files)
        vim.keymap.set("n", "<leader>rc", function()
            require("molten-cells").run_cell()
        end, { buffer = true, desc = "Run cell", silent = true })

        vim.keymap.set("v", "<leader>r", function()
            vim.cmd("MoltenEvaluateVisual")
        end, { buffer = true, desc = "Run selection", silent = true })

        vim.keymap.set("n", "<leader>rr", ":MoltenReevaluateCell<CR>", { buffer = true, desc = "Re-run cell", silent = true })

        -- Output management
        vim.keymap.set("n", "<leader>ro", ":MoltenShowOutput<CR>", { buffer = true, desc = "Show output", silent = true })
        vim.keymap.set("n", "<leader>rh", ":MoltenHideOutput<CR>", { buffer = true, desc = "Hide output", silent = true })
        vim.keymap.set("n", "<leader>rd", ":MoltenDelete<CR>", { buffer = true, desc = "Delete cell", silent = true })

        -- Cell navigation (understands # %% markers)
        vim.keymap.set("n", "]c", function()
            require("molten-cells").next_cell()
        end, { buffer = true, desc = "Next cell", silent = true })
        vim.keymap.set("n", "[c", function()
            require("molten-cells").prev_cell()
        end, { buffer = true, desc = "Previous cell", silent = true })

        -- Interrupt/restart
        vim.keymap.set("n", "<leader>ri", ":MoltenInterrupt<CR>", { buffer = true, desc = "Interrupt kernel", silent = true })
        vim.keymap.set("n", "<leader>rx", ":MoltenRestart!<CR>", { buffer = true, desc = "Restart kernel", silent = true })
    end,
})
