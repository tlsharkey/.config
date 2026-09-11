require("conform").setup({
  formatters_by_ft = {
    -- Lua/Config
    lua = { "stylua" },

    -- Web Development (use stop_after_first to run only the first available formatter)
    javascript = { "prettier", "prettierd", stop_after_first = true },
    typescript = { "prettier", "prettierd", stop_after_first = true },
    javascriptreact = { "prettier", "prettierd", stop_after_first = true },
    typescriptreact = { "prettier", "prettierd", stop_after_first = true },
    css = { "prettier", "prettierd", stop_after_first = true },
    scss = { "prettier", "prettierd", stop_after_first = true },
    html = { "prettier", "prettierd", stop_after_first = true },
    json = { "prettier", "prettierd", stop_after_first = true },
    jsonc = { "prettier", "prettierd", stop_after_first = true },
    -- YAML formatted via LSP (yamlls) to dynamically follow buffer indentation
    yaml = {},
    -- Do not format Helm templates with standard YAML formatters
    helm = {},
    markdown = { "prettier", "prettierd", stop_after_first = true },

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

    -- Config files
    toml = { "taplo" },
  },
  formatters = {
    -- Configure prettier to use 4 spaces by default
    prettier = {
      prepend_args = { "--tab-width", "4" },
    },
    -- Configure shfmt to use spaces instead of tabs
    shfmt = {
      prepend_args = { "-i", "4", "-s" }, -- indent 4 spaces, simplify code
    },
    -- Configure taplo to use 4 space indentation
    taplo = {
      prepend_args = { "fmt", "--option", "indent_string=    " }, -- 4 spaces
    },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
  format_on_save = function(bufnr)
    local ft = vim.bo[bufnr].filetype
    -- Never autoformat Helm templates
    if ft == "helm" then
      return nil
    end

    -- Safeguard for any YAML file (yaml, yaml.*) containing template expressions
    if ft == "yaml" or ft:match("^yaml%.") then
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 50, false)
      for _, line in ipairs(lines) do
        if line:match("{{") then
          return nil
        end
      end
    end

    return {
      timeout_ms = 500,
      lsp_format = "fallback",
    }
  end,
})
