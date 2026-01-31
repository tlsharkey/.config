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
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = { "markdown" },
    disable = { "latex" },
  },
  ensure_installed = { "markdown", "markdown_inline", "lua", "vim", "vimdoc" },
  auto_install = true,
}

vim.filetype.add({
  extension = {
    jsonl = "json",
  },
})
