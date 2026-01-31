local colorscheme = "vscode"

local is_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not is_ok then
    vim.notify("colorscheme " .. colorscheme .. " not found!")
    return
end



vim.api.nvim_set_hl(0, 'RenderMarkdownCheckboxZero',  { fg = '#D77C89' })
vim.api.nvim_set_hl(0, 'RenderMarkdownCheckboxOne',   { fg = '#E09B76' })
vim.api.nvim_set_hl(0, 'RenderMarkdownCheckboxTwo',   { fg = '#DAC192' })
vim.api.nvim_set_hl(0, 'RenderMarkdownCheckboxThree', { fg = '#97C688' })
vim.api.nvim_set_hl(0, 'RenderMarkdownCheckboxFour',  { fg = '#7FC2B9' })
vim.api.nvim_set_hl(0, 'RenderMarkdownCheckboxFive',  { fg = '#87C4CF' })
vim.api.nvim_set_hl(0, 'RenderMarkdownCheckboxSix',   { fg = '#7E9FDF' })
vim.api.nvim_set_hl(0, 'RenderMarkdownCheckboxSeven', { fg = '#B594E1' })
vim.api.nvim_set_hl(0, 'RenderMarkdownCheckboxEight', { fg = '#D8838B' })
vim.api.nvim_set_hl(0, 'RenderMarkdownCheckboxNine',  { fg = '#B597E1' })



