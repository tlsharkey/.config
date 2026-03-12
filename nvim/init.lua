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

vim.filetype.add({
  extension = {
    jsonl = "json",
  },
})
