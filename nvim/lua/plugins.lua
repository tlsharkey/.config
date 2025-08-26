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
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            { "mason-org/mason.nvim", opts = {
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            } },
            "neovim/nvim-lspconfig",
        },
    },
    "neovim/nvim-lspconfig",
    "OmniSharp/omnisharp-vim",
    "Hoffs/omnisharp-extended-lsp.nvim",
    "pangloss/vim-javascript",
    "maxmellon/vim-jsx-pretty",
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
                        accept = "<C-Down>",
                        accept_word = "<C-S-Right>",
                        accept_line = "<C-Right>",
                        next = "<C-Up>",
                        -- prev = "<C-Up>",
                        dismiss = false,
                    },
                },
            })
        end
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 
            'nvim-treesitter/nvim-treesitter', 
            'nvim-tree/nvim-web-devicons',
            'echasnovski/mini.icons'
        },
        ft = { "markdown", "quarto" },
        config = function()
            require("render-markdown").setup({
                enabled = true,
                file_types = { "markdown", "quarto" },
                render_modes = true,
                latex = { enabled = false },
                html = { enabled = false },
                -- Use the beautiful Unicode icons since your terminal supports them
                heading = {
                    enabled = true,
                    icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
                },
                bullet = {
                    enabled = true,
                    icons = { "●", "○", "◆", "◇" },
                },
                checkbox = {
                    enabled = true,
                    checked = {
                        icon = " ",
                        highlight = "RenderMarkdownChecked",
                    },
                    unchecked = {
                        icon = "󰄱 ",
                        highlight = "RenderMarkdownUnchecked",
                    },
                    custom = {
                        -- inprogress = { raw = "[/]", hightlight="DiagnosticWarn" },
                        in_progress = { raw = '[/]', rendered = '󱎖 ', highlight = 'Comment' },
                        zero =  { raw = '[0]', rendered = '󰎡 ', highlight = 'RenderMarkdownCheckboxZero' },
                        one =   { raw = '[1]', rendered = '󰎤 ', highlight = 'RenderMarkdownCheckboxOne' },
                        two =   { raw = '[2]', rendered = '󰎧 ', highlight = 'RenderMarkdownCheckboxTwo' },
                        three = { raw = '[3]', rendered = '󰎪 ', highlight = 'RenderMarkdownCheckboxThree' },
                        four =  { raw = '[4]', rendered = '󰎭 ', highlight = 'RenderMarkdownCheckboxFour' },
                        five =  { raw = '[5]', rendered = '󰎱 ', highlight = 'RenderMarkdownCheckboxFive' },
                        six =   { raw = '[6]', rendered = '󰎳 ', highlight = 'RenderMarkdownCheckboxSix' },
                        seven = { raw = '[7]', rendered = '󰎶 ', highlight = 'RenderMarkdownCheckboxSeven' },
                        eight = { raw = '[8]', rendered = '󰎹 ', highlight = 'RenderMarkdownCheckboxEight' },
                        nine =  { raw = '[9]', rendered = '󰎼 ', highlight = 'RenderMarkdownCheckboxNine' },
                        cancelled = { raw = '[-]', rendered = ' ', highlight = 'Comment', scope_highlight = 'Strikethrough' },
                        urgent = { raw = '[!]', rendered = ' ', highlight = 'ErrorMsg' }, -- Exclamation icon
                        question = { raw = '[?]', rendered = ' ', highlight = 'Question' }, -- Questionmark icon

                    }
                },
                -- Enable debugging to see what's happening
                log_level = "info",
            })
        end,
    },
    -- GUI Stuff
    {
        "echasnovski/mini.icons",
        opts = {},
        lazy = true,
        specs = {
            { "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
        },
        init = function()
            package.preload["nvim-web-devicons"] = function()
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
            -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
        },
        lazy = false, -- neo-tree will lazily load itself
        ---@module "neo-tree"
        ---@type neotree.Config?
        opts = {
            -- fill any relevant options here
            window = {
                width = 30,
                mappings = {
                    ["P"] = {
                        "toggle_preview",
                        config = {
                            use_float = true,
                        },
                    },
                },
            },
            filesystem = {
                filtered_items = {
                    visible = true,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
            }
        },
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            defaults = {
               file_ignore_patterns = {
                   "node_modules",
                   "build",
                   "dist",
                   "%.d%.ts$",
                   "%.git/",
                   "__pycache__/",
                   "target/",
                   "vendor/",
                   "%.jar",
                   "%.war",
                   "%.lock",
                   "%.DS_Store",
               },
           },
       },
    },
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = 'nvim-tree/nvim-web-devicons'
    },
})

