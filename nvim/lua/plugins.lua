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
    -- Code snippet engine
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        event = "InsertEnter",
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
                    -- Web Development
                    "html",           -- HTML
                    "cssls",          -- CSS
                    "ts_ls",          -- TypeScript/JavaScript
                    "eslint",         -- JS/TS linting
                    "tailwindcss",    -- Tailwind CSS

                    -- Backend/Systems
                    "rust_analyzer",  -- Rust
                    "gopls",          -- Go
                    "pyright",        -- Python
                    "omnisharp",      -- C# (Unity, .NET)

                    -- Config/Data formats
                    "jsonls",         -- JSON
                    "yamlls",         -- YAML
                    "taplo",          -- TOML
                    "lua_ls",         -- Lua (Neovim config)

                    -- DevOps/Infrastructure
                    "bashls",         -- Bash/Shell scripts
                    "dockerls",       -- Dockerfile
                    "docker_compose_language_service", -- Docker Compose

                    -- Markup/Documentation
                    "marksman",       -- Markdown
                }
            })
            
            -- Ensure binaries for conform.nvim are also available
            require("mason").setup()
            local registry = require("mason-registry")
            local formatters = {
                "prettier",    -- JS/TS/HTML/CSS/JSON/YAML/Markdown
                "stylua",      -- Lua
                "black",       -- Python
                "isort",       -- Python imports
                "csharpier",   -- C#
                "rustfmt",     -- Rust (usually installed with Rust toolchain)
                "gofumpt",     -- Go (stricter gofmt)
                "shfmt",       -- Shell scripts
            }
            for _, formatter in ipairs(formatters) do
                local ok, p = pcall(registry.get_package, registry, formatter)
                if ok and not p:is_installed() then
                    -- Install async so it doesn't block startup/shutdown
                    vim.schedule(function()
                        pcall(function() p:install() end)
                    end)
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

            vim.lsp.config("eslint", {
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
                settings = {
                    format = { enable = true },
                    rules = {
                        indent = { "error", 4 },
                    },
                },
            })

            vim.lsp.config("ts_ls", {
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            })

            vim.lsp.config("html", {
                filetypes = { "html", "htmldjango" },
            })

            vim.lsp.config("cssls", {
                filetypes = { "css", "scss", "less" },
            })

            vim.lsp.config("tailwindcss", {
                filetypes = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact" },
            })

            vim.lsp.config("rust_analyzer", {
                filetypes = { "rust" },
                root_dir = vim.fs.root(0, { "Cargo.toml" }),
                settings = {
                    ["rust-analyzer"] = {
                        cargo = { allFeatures = true },
                        checkOnSave = { command = "clippy" },
                    },
                },
            })

            vim.lsp.config("gopls", {
                filetypes = { "go", "gomod", "gowork", "gotmpl" },
                root_dir = vim.fs.root(0, { "go.work", "go.mod", ".git" }),
            })

            vim.lsp.config("pyright", {
                filetypes = { "python" },
            })

            vim.lsp.config("omnisharp", {
                filetypes = { "cs" },
                root_dir = vim.fs.root(0, { ".git", ".sln", ".csproj" }),
            })

            vim.lsp.config("yamlls", {
                filetypes = { "yaml", "yaml.docker-compose" },
            })

            vim.lsp.config("taplo", {
                filetypes = { "toml" },
            })

            vim.lsp.config("bashls", {
                filetypes = { "sh", "bash", "zsh" },
            })

            vim.lsp.config("dockerls", {
                filetypes = { "dockerfile" },
            })

            vim.lsp.config("docker_compose_language_service", {
                filetypes = { "yaml.docker-compose" },
            })

            vim.lsp.config("marksman", {
                filetypes = { "markdown" },
            })

            vim.lsp.config("lua_ls", {
                filetypes = { "lua" },
            })

            -- 3. To actually "start" the server automatically based on the config above
            -- Web Development
            vim.lsp.enable("html")
            vim.lsp.enable("cssls")
            vim.lsp.enable("ts_ls")
            vim.lsp.enable("eslint")
            vim.lsp.enable("tailwindcss")

            -- Backend/Systems
            vim.lsp.enable("rust_analyzer")
            vim.lsp.enable("gopls")
            vim.lsp.enable("pyright")
            vim.lsp.enable("omnisharp")

            -- Config/Data formats
            vim.lsp.enable("jsonls")
            vim.lsp.enable("yamlls")
            vim.lsp.enable("taplo")
            vim.lsp.enable("lua_ls")

            -- DevOps/Infrastructure
            vim.lsp.enable("bashls")
            vim.lsp.enable("dockerls")
            vim.lsp.enable("docker_compose_language_service")

            -- Markup/Documentation
            vim.lsp.enable("marksman")
        end
    },

    "Hoffs/omnisharp-extended-lsp.nvim",
    -- "pangloss/vim-javascript",
    -- "maxmellon/vim-jsx-pretty",
    {
        "numToStr/Comment.nvim",
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        opts = function()
            return {
                pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
            }
        end,
        event = { "BufReadPost", "BufNewFile" },
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
        event = "InsertEnter",
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
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        config = function()
            -- Configure context commentstring for TSX/JSX
            require('ts_context_commentstring').setup({
                enable_autocmd = false,
            })

            -- Enable treesitter highlighting for specific filetypes
            vim.api.nvim_create_autocmd('FileType', {
                pattern = {
                    'lua', 'vim', 'vimdoc',
                    'html', 'css', 'scss', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact',
                    'python', 'rust', 'go', 'cs',
                    'json', 'jsonc', 'yaml', 'toml',
                    'sh', 'bash', 'zsh', 'dockerfile',
                    'markdown',
                },
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
        "3rd/image.nvim",
        ft = { "markdown", "quarto" },
        -- Only enable if we have imagemagick and terminal supports images
        cond = function()
            -- Check if imagemagick is installed
            if vim.fn.executable("magick") == 0 and vim.fn.executable("convert") == 0 then
                return false
            end
            -- Check terminal support
            local term = vim.env.TERM_PROGRAM or vim.env.TERM or ""
            return term:match("iTerm") or term:match("kitty") or term:match("WezTerm") or vim.fn.executable("ueberzugpp") == 1
        end,
        build = false,  -- Don't auto-build, let it manage itself
        opts = {
            backend = "kitty",  -- iTerm2 supports kitty protocol
            integrations = {
                markdown = {
                    enabled = true,
                    clear_in_insert_mode = false,
                    download_remote_images = true,
                    only_render_image_at_cursor = false,
                },
            },
            max_width = 100,
            max_height = 12,
            max_height_window_percentage = 50,
            window_overlap_clear_enabled = false,
            window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        },
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
            'echasnovski/mini.icons',
            '3rd/image.nvim'
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
                -- Mermaid diagram support
                code = {
                    enabled = true,
                    sign = true,
                    style = 'full',
                    position = 'left',
                    width = 'block',
                    left_pad = 0,
                    right_pad = 0,
                    min_width = 0,
                    language_pad = 0,
                    border = 'thin',
                    above = '▄',
                    below = '▀',
                    highlight = 'RenderMarkdownCode',
                    highlight_inline = 'RenderMarkdownCodeInline',
                },
                pipe_table = {
                    enabled = true,
                    preset = 'round',
                    style = 'full',
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
        'iamcco/markdown-preview.nvim',
        cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
        ft = { 'markdown' },
        build = 'cd app && npm install && git checkout .',
        config = function()
            vim.g.mkdp_auto_close = 0  -- Don't auto-close preview when switching buffers
            vim.g.mkdp_theme = 'dark'
            vim.g.mkdp_filetypes = { 'markdown' }
            vim.g.mkdp_browser = ''  -- Use system default browser

            -- Keymaps
            vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreview<cr>', { desc = 'Markdown Preview (browser)' })
            vim.keymap.set('n', '<leader>ms', '<cmd>MarkdownPreviewStop<cr>', { desc = 'Stop Markdown Preview' })
        end,
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
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require("config.bufferline")
        end,
    },
    {
        "img-paste-devs/img-paste.vim",
        ft = { "markdown", "quarto" },
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
    -- UI Enhancements
    {
        "rcarriga/nvim-notify",
        config = function()
            local notify = require("notify")
            notify.setup({
                stages = "slide",  -- Smooth slide animation from right edge
                timeout = 3000,
                background_colour = "#000000",
                top_down = false,  -- Default to bottom-right, will override if cursor is at top
                on_open = function(win)
                    -- Get cursor position in the current window
                    local cursor_line = vim.fn.line('.')
                    local win_height = vim.fn.winheight(0)
                    local win_top = vim.fn.line('w0')

                    -- Calculate if cursor is in top 30% of visible window
                    local cursor_relative = cursor_line - win_top + 1
                    local is_cursor_at_top = (cursor_relative / win_height) < 0.3

                    -- If cursor is at top, move notification to bottom
                    -- If cursor is at bottom/middle, move notification to top
                    if is_cursor_at_top then
                        -- Position at bottom-right
                        vim.api.nvim_win_set_config(win, {
                            relative = "editor",
                            anchor = "SE",
                            row = vim.o.lines - 2,
                            col = vim.o.columns,
                        })
                    else
                        -- Position at top-right (default)
                        vim.api.nvim_win_set_config(win, {
                            relative = "editor",
                            anchor = "NE",
                            row = 1,
                            col = vim.o.columns,
                        })
                    end
                end,
            })

            -- Wrap vim.notify to log filetype messages before they're filtered by noice
            local original_notify = notify
            vim.notify = function(msg, level, opts)
                local msg_str = tostring(msg)
                local lower_msg = msg_str:lower()

                -- Log filetype-related messages to file
                if lower_msg:match("filetype") or lower_msg:match("unknown") then
                    local log_file = vim.fn.expand("~/.config/nvim/unknownfiletypes.txt")
                    local file = io.open(log_file, "a")
                    if file then
                        file:write(string.format("[%s] Level: %s - %s\n",
                            os.date("%Y-%m-%d %H:%M:%S"),
                            tostring(level or "INFO"),
                            msg_str))
                        file:close()
                    end
                end

                -- Still call original notify (noice will filter it for display)
                original_notify(msg, level, opts)
            end
        end,
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                inc_rename = false,
                lsp_doc_border = true,
            },
            routes = {
                {
                    filter = {
                        event = "notify",
                        find = "filetype",
                    },
                    opts = { skip = true },
                },
                {
                    filter = {
                        event = "notify",
                        find = "unknown",
                    },
                    view = "mini",
                    opts = {
                        -- Log it but show in cmdline instead of popup
                        skip = false,
                    },
                },
            },
        },
    },
    {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "petertriho/nvim-scrollbar",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("scrollbar").setup({
                handle = {
                    color = "#3b4261",
                },
                marks = {
                    Search = { color = "#ff9e64" },
                    Error = { color = "#db4b4b" },
                    Warn = { color = "#e0af68" },
                    Info = { color = "#0db9d7" },
                    Hint = { color = "#1abc9c" },
                    Misc = { color = "#9d7cd8" },
                },
            })
        end,
    },
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
            { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
            { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
        },
        opts = {},
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            indent = {
                char = "│",
            },
            scope = {
                enabled = true,
                show_start = true,
                show_end = false,
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        opts = {
            options = {
                theme = "auto",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                globalstatus = true,
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            delay = 500,
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },
})

