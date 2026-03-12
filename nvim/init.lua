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
  },
})
