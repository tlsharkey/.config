-- Python provider for pynvim (used by molten-nvim)
local venv_python = vim.fn.expand("~/.config/nvim/.venv/bin/python3")
if vim.fn.filereadable(venv_python) == 1 then
  vim.g.python3_host_prog = venv_python
end

require("options")
require("filetypes")
require("keymaps")

-- LuaRocks modules for Lua 5.1 (Neovim uses LuaJIT 5.1, not system Lua 5.4)
-- mega.cmdparse and mega.logging are avante.nvim dependencies
local luarocks_51 = os.getenv("HOME") .. "/.luarocks/share/lua/5.1"
package.path = luarocks_51 .. "/?.lua;" .. luarocks_51 .. "/?/init.lua;" .. package.path

-- Must run before plugins: it puts TeX on PATH, which VimTeX's enable check and
-- its latexmk job both depend on.
require("latex").setup()
require("plugins")
require("colorscheme")

