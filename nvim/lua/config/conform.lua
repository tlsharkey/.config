require("conform").setup({
  formatters_by_ft = {
    -- Lua/Config
    lua = { "stylua" },

    -- Web Development (use sub-list to run only the first available formatter)
    javascript = { { "prettierd", "prettier" } },
    typescript = { { "prettierd", "prettier" } },
    javascriptreact = { { "prettierd", "prettier" } },
    typescriptreact = { { "prettierd", "prettier" } },
    css = { { "prettierd", "prettier" } },
    scss = { { "prettierd", "prettier" } },
    html = { { "prettierd", "prettier" } },
    json = { { "prettierd", "prettier" } },
    jsonc = { { "prettierd", "prettier" } },
    yaml = { { "prettierd", "prettier" } },
    markdown = { { "prettierd", "prettier" } },

    -- Backend/Systems
    python = { "isort", "black" },
    rust = { "rustfmt" },
    go = { "gofumpt" },
    cs = { "csharpier" },
    csharp = { "csharpier" },

    -- Shell scripts
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
  },
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
