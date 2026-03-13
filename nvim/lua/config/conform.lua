require("conform").setup({
  formatters_by_ft = {
    -- Lua/Config
    lua = { "stylua" },

    -- Web Development (use stop_after_first to run only the first available formatter)
    javascript = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    css = { "prettierd", "prettier", stop_after_first = true },
    scss = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },
    jsonc = { "prettierd", "prettier", stop_after_first = true },
    yaml = { "prettierd", "prettier", stop_after_first = true },
    markdown = { "prettierd", "prettier", stop_after_first = true },

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
  formatters = {
    -- Configure prettier to use 4 spaces by default
    prettier = {
      prepend_args = { "--tab-width", "4" },
    },
    prettierd = {
      prepend_args = { "--tab-width", "4" },
    },
    -- Configure shfmt to use spaces instead of tabs
    shfmt = {
      prepend_args = { "-i", "4", "-s" }, -- indent 4 spaces, simplify code
    },
  },
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
