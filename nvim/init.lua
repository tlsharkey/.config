-- Python provider for pynvim (used by molten-nvim)
local venv_python = vim.fn.expand("~/.config/nvim/.venv/bin/python3")
if vim.fn.filereadable(venv_python) == 1 then
  vim.g.python3_host_prog = venv_python
end

require("options")
require("filetypes")
require("keymaps")
-- Must run before plugins: it puts TeX on PATH, which VimTeX's enable check and
-- its latexmk job both depend on.
require("latex").setup()
require("plugins")
require("colorscheme")

