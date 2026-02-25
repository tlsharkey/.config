require("options")
require("keymaps")
require("plugins")
require("colorscheme")
require("lsp")
require('omnisharp_extended')
require('diffview')
require("neo-tree")

vim.opt.termguicolors = true

require("bufferline").setup{}

-- Install required parsers
require('nvim-treesitter').install({ 'markdown', 'markdown_inline', 'lua', 'vim', 'vimdoc' })

-- Enable treesitter highlighting for specific filetypes
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'lua', 'vim', 'vimdoc' },
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

vim.filetype.add({
  extension = {
    jsonl = "json",
  },
})
