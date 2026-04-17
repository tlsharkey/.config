require("options")
require("keymaps")
require("plugins")
require("colorscheme")
require("lsp")
require('diffview')
require("neo-tree")

vim.filetype.add({
  extension = {
    jsonl = "json",
    parquet = "parquet",
  },
})

-- Auto-display parquet files using parquet-tools
vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = "*.parquet",
  callback = function()
    local filepath = vim.fn.expand("<afile>")
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "hide"
    vim.bo.swapfile = false

    local lines = {}
    table.insert(lines, "=== Parquet File: " .. vim.fn.fnamemodify(filepath, ":t") .. " ===")
    table.insert(lines, "")

    -- Check if parquet-tools is installed
    if vim.fn.executable("parquet-tools") == 0 then
      table.insert(lines, "ERROR: parquet-tools is not installed")
      table.insert(lines, "")
      table.insert(lines, "To view Parquet files, please install parquet-tools:")
      table.insert(lines, "")
      table.insert(lines, "  macOS:   brew install parquet-tools")
      table.insert(lines, "  Linux:   go install github.com/hangxie/parquet-tools@latest")
      table.insert(lines, "")
      table.insert(lines, "Or download from: https://github.com/hangxie/parquet-tools/releases")

      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      vim.bo.filetype = "text"
      vim.bo.modifiable = false
      vim.bo.readonly = true
      return
    end

    -- Read schema (pretty-printed with jq if available)
    local schema_cmd = "parquet-tools schema " .. vim.fn.shellescape(filepath)
    if vim.fn.executable("jq") == 1 then
      schema_cmd = schema_cmd .. " | jq ."
    end
    local schema_output = vim.fn.systemlist(schema_cmd)
    local schema_exit_code = vim.v.shell_error

    -- Read data (pretty-printed with jq if available)
    local data_cmd = "parquet-tools cat " .. vim.fn.shellescape(filepath)
    if vim.fn.executable("jq") == 1 then
      data_cmd = data_cmd .. " | jq ."
    end
    local data_output = vim.fn.systemlist(data_cmd)
    local data_exit_code = vim.v.shell_error

    -- Handle errors
    if schema_exit_code ~= 0 or data_exit_code ~= 0 then
      table.insert(lines, "ERROR: Failed to read Parquet file")
      table.insert(lines, "")
      if schema_exit_code ~= 0 then
        table.insert(lines, "Schema error:")
        vim.list_extend(lines, schema_output)
        table.insert(lines, "")
      end
      if data_exit_code ~= 0 then
        table.insert(lines, "Data error:")
        vim.list_extend(lines, data_output)
      end

      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      vim.bo.filetype = "text"
      vim.bo.modifiable = false
      vim.bo.readonly = true
      return
    end

    -- Combine successful output
    table.insert(lines, "--- Schema ---")
    vim.list_extend(lines, schema_output)
    table.insert(lines, "")
    table.insert(lines, "--- Data ---")
    vim.list_extend(lines, data_output)

    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.bo.filetype = "json"  -- Use json filetype for syntax highlighting
    vim.bo.modifiable = false
    vim.bo.readonly = true
  end,
})
