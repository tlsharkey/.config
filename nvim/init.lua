-- Python provider for pynvim (used by molten-nvim)
vim.g.python3_host_prog = vim.fn.expand("~/.config/nvim/.venv/bin/python3")

require("options")
require("keymaps")
require("plugins")
require("colorscheme")
require("lsp")
require('diffview')
require("neo-tree")
require("filetypes")

