--- lazy.nvim installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Vscode-like pictograms
    {
        "onsails/lspkind.nvim",
        event = { "VimEnter" },
    },
    -- Auto-completion engine
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "lspkind.nvim",
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp", -- lsp auto-completion
            "hrsh7th/cmp-buffer", -- buffer auto-completion
            "hrsh7th/cmp-path", -- path auto-completion
            "hrsh7th/cmp-cmdline", -- cli auto-completion
        },
        config = function()
            require("config.nvim-cmp")
        end,
    },
    -- Code sippet engine
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*"
    },
    -- LSP manager
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "OmniSharp/omnisharp-vim",
    "Hoffs/omnisharp-extended-lsp.nvim",
    -- Colorscheme
    "tanvirtin/monokai.nvim",
    "Mofiqul/vscode.nvim",
    "tomasiser/vim-code-dark",
    "olimorris/onedarkpro.nvim",
    -- merge tool
    "sindrets/diffview.nvim",
    -- gutentags (like intellisense)
    "ludovicchabant/vim-gutentags",
    {
        "Exafunction/codeium.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            require("codeium").setup({
                virtual_text = {
                    enabled = true,
                    key_bindings = {
                        accept = "<C-CR>", -- competing with other auto-completion
                        accept_word = "<C-Right>",
                        accept_line = "<C-S-Right>",
                        next = "<C-Down>",
                        prev = "<C-Up>",
                        dismiss = false,
                    },
                },
            })
        end
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    }
})

