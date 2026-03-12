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
        "neovim/nvim-lspconfig",
        dependencies = {
            { 
                "mason-org/mason.nvim", 
                opts = { ui = { icons = { package_installed = "✓" } } } 
            },
            "mason-org/mason-lspconfig.nvim",
        },
        config = function()
            -- 1. Setup Mason to bridge with lspconfig
            require("mason-lspconfig").setup({
                ensure_installed = { 
                    "jsonls",
                    "eslint",
                    "lua_ls",
                    "pyright",
                }
            })
            
            -- Ensure binaries for conform.nvim are also available
            require("mason").setup()
            local registry = require("mason-registry")
            local formatters = { "prettier", "stylua", "black", "isort" }
            for _, formatter in ipairs(formatters) do
                local p = registry.get_package(formatter)
                if not p:is_installed() then
                    p:install()
                end
            end

            -- 2. New 0.11+ / v3.0 syntax: Use vim.lsp.config
            -- We define the configuration for jsonls
            vim.lsp.config("jsonls", {
                -- We explicitly exclude "jsonl" from being handled by the LSP
                -- This keeps highlighting (via filetype) but prevents LSP errors
                filetypes = { "json", "jsonc" },
                settings = {
                    json = {
                        validate = { enable = true },
                    },
                },
            })

            -- 3. To actually "start" the server automatically based on the config above
            vim.lsp.enable("jsonls")
            vim.lsp.enable("omnisharp")
            vim.lsp.enable("eslint")
            vim.lsp.enable("lua_ls")
            vim.lsp.enable("pyright")
        end
    },

    "OmniSharp/omnisharp-vim",
    "Hoffs/omnisharp-extended-lsp.nvim",
    -- "pangloss/vim-javascript",
    -- "maxmellon/vim-jsx-pretty",
    {
        "numToStr/Comment.nvim",
        opts = {},
        lazy = false,
    },
    -- Colorscheme
    "tanvirtin/monokai.nvim",
    "Mofiqul/vscode.nvim",
    "tomasiser/vim-code-dark",
    "olimorris/onedarkpro.nvim",
    { import = "config.neoscroll" },
    -- merge tool
    "sindrets/diffview.nvim",
    -- gutentags (like intellisense)
    {
        "ludovicchabant/vim-gutentags",
        config = function()
            vim.g.gutentags_ctags_tagfile = ".tags"
            vim.g.gutentags_enabled = 1
            vim.g.gutentags_generate_on_new = 1
            local ctags_config = vim.fn.expand("~/.config/ctags")
            if vim.fn.filereadable(ctags_config) == 1 then
                vim.g.gutentags_ctags_extra_args = { "--options=" .. ctags_config }
            end
            vim.g.gutentags_exclude_filetypes = {}
            vim.g.gutentags_ctags_exclude_project_roots = {
                "~/.config",
                "/usr/local",
                "/opt/homebrew",
                "/home/linuxbrew/.linuxbrew",
            }
            -- vim.g.gutentags_ctags_tagfile = ".tags"
            vim.g.gutentags_project_root = { ".git", ".hg", ".svn", ".bzr", ".root" }
            -- vim.g.gutentags_trace = 1
        end
    },
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
    -- Tree-sitter for syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            -- Install required parsers
            require('nvim-treesitter').install({
                'markdown', 'markdown_inline', 'lua', 'vim', 'vimdoc',
                'python', 'javascript', 'typescript', 'json', 'c_sharp'
            })

            -- Enable treesitter highlighting for specific filetypes
            vim.api.nvim_create_autocmd('FileType', {
                pattern = { 'markdown', 'lua', 'vim', 'vimdoc', 'python', 'javascript', 'typescript', 'json' },
                callback = function()
                    vim.treesitter.start()
                end,
            })

            -- Disable treesitter for latex
            vim.api.nvim_create_autocmd('FileType', {
                pattern = { 'latex', 'tex' },
                callback = function()
                    vim.treesitter.stop()
                end,
            })
        end,
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
    {
        'jghauser/follow-md-links.nvim'
    },
    {
        "lervag/vimtex",
        lazy = false,     -- we don't want to lazy load VimTeX
        init = function()
          if vim.fn.executable("skim") == 1 then
            vim.g.vimtex_view_method = "skim"
          elseif vim.fn.executable("zathura") == 1 then
            vim.g.vimtex_view_method = "zathura"
          elseif vim.fn.executable("evince") == 1 then
            vim.g.vimtex_view_method = "evince"
          elseif vim.fn.executable("okular") == 1 then
            vim.g.vimtex_view_method = "okular"
          elseif vim.fn.executable("mupdf") == 1 then
            vim.g.vimtex_view_method = "mupdf"
          end
          vim.g.vimtex_compiler_latexmk = {
              out_dir = ".latex",
          }
        end
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
        config = function()
            local previewers_utils = require('telescope.previewers.utils')

            -- Override the default highlighter to not use treesitter
            -- This fixes compatibility with treesitter v3.0+ API changes
            previewers_utils.highlighter = function(bufnr, ft)
                -- Use vim's regex-based syntax highlighting instead of treesitter
                vim.bo[bufnr].syntax = 'on'
                if ft and ft ~= '' then
                    pcall(vim.cmd, 'setlocal filetype=' .. ft)
                end
            end

            require('telescope').setup({
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
            })
        end,
    },
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = 'nvim-tree/nvim-web-devicons'
    },
    {
        "img-paste-devs/img-paste.vim",
    },
    -- Python Notebooks
    {
        'goerz/jupytext.nvim',
        version = '0.2.0',
        opts = {},
    },
    {
        "quarto-dev/quarto-nvim", -- code snippet code completion, execution
        dependencies = {
            "jmbuhr/otter.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
    },
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        config = function()
            require("config.conform")
        end,
    },
})

