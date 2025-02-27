require("options")
require("keymaps")
require("plugins")
require("colorscheme")
require("lsp")
require('omnisharp_extended')
require('diffview')
require("render-markdown").setup({
    enabled = true,
    file_types = { "markdown", "quarto" },
    render_modes = true -- { "n", "c", "t" },
})
