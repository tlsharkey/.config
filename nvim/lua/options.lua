-- General
vim.opt.background = "dark"
vim.opt.clipboard = "unnamedplus" -- uses system clipboard
vim.opt.wildmenu = true -- show a navigation menu for tab completion


-- Hint: use `:h <option>` to figure out the meaning if needed
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
vim.opt.mouse = 'a'                 -- allow the mouse to be used in Nvim

-- Tab
vim.opt.tabstop = 4                 -- number of visual spaces per TAB
vim.opt.softtabstop = 4             -- number of spacesin tab when editing
vim.opt.shiftwidth = 4              -- insert 4 spaces on a tab
vim.opt.expandtab = true            -- tabs are spaces, mainly because of python
vim.opt.smarttab = true

-- UI config
vim.opt.number = true               -- show absolute number
-- vim.opt.cursorline = true           -- highlight cursor line underneath the cursor horizontally
vim.opt.splitbelow = true           -- open new vertical split bottom
vim.opt.splitright = true           -- open new horizontal splits right
vim.opt.termguicolors = true        -- enable 24-bit RGB color in the TUI
-- vim.opt.showmode = false            -- we are experienced, wo don't need the "-- INSERT --" mode hint
-- show spaces as interpunc
vim.opt.lcs = "trail:·"
vim.opt.list = true

-- Folding configuration - use indent by default (reliable everywhere)
vim.opt.foldmethod = "indent"
vim.opt.foldnestmax = 5
vim.opt.foldlevel = 99  -- Start with all folds open
vim.opt.foldlevelstart = 99

-- Custom markdown folding based on headers
function _G.markdown_fold_expr()
    local line = vim.fn.getline(vim.v.lnum)
    local next_line = vim.fn.getline(vim.v.lnum + 1)

    -- Check if current line is a header (starts with #)
    local header_level = line:match("^(#+)%s")
    if header_level then
        return ">" .. #header_level
    end

    -- Check for setext-style headers (underlined with = or -)
    if next_line:match("^=+%s*$") then
        return ">1"
    elseif next_line:match("^-+%s*$") then
        return ">2"
    end

    -- For all other lines (including code blocks), maintain the current fold level
    -- This ensures long code blocks stay within their parent header's fold
    return "="
end

-- Try treesitter folding for code languages
vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        'lua', 'vim', 'python', 'javascript', 'javascriptreact',
        'typescript', 'typescriptreact', 'rust', 'go', 'c', 'cpp', 'cs',
    },
    callback = function()
        -- Try to use treesitter folding if available
        local ok, _ = pcall(vim.treesitter.get_parser)
        if ok then
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.opt_local.foldlevel = 99
        end
    end,
})

-- Use custom markdown folding
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.foldmethod = "expr"
        vim.opt_local.foldexpr = "v:lua.markdown_fold_expr()"
        vim.opt_local.foldlevel = 99  -- Start with all folds open
    end,
})

-- Searching
vim.opt.incsearch = true            -- search as characters are entered
-- vim.opt.hlsearch = false            -- do not highlight matches
vim.opt.ignorecase = true           -- ignore case in searches by default
vim.opt.smartcase = true            -- but make it case sensitive if an uppercase is entered

-- Line wrapping
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.scrolloff = 3

-- Undo directory
local undodir = vim.fn.expand("~/.vim/undo")
if vim.fn.isdirectory(undodir) == 1 then
    vim.opt.undodir = undodir
end

-- Filetype-specific indentation
vim.api.nvim_create_autocmd("FileType", {
    pattern = "toml",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
    end,
})
