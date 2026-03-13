-- Customized on_attach function
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }

-- Helper to jump to definition from within floating windows
local function goto_definition_from_float()
    local word = vim.fn.expand('<cword>')
    -- Close all floating windows
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) then
            local success, config = pcall(vim.api.nvim_win_get_config, win)
            if success and config.relative ~= "" then
                pcall(vim.api.nvim_win_close, win, false)
            end
        end
    end
    -- Search for the word in the current buffer and go to definition
    vim.fn.search(word, 'w')
    vim.lsp.buf.definition()
end

-- Setup autocmd to add keymap when entering floating windows
vim.api.nvim_create_autocmd("WinEnter", {
    pattern = "*",
    callback = function()
        local win = vim.api.nvim_get_current_win()
        -- Check if window is valid before getting config
        if not vim.api.nvim_win_is_valid(win) then
            return
        end

        local success, config = pcall(vim.api.nvim_win_get_config, win)
        if success and config.relative ~= "" then  -- We're in a floating window
            vim.keymap.set('n', 'gd', goto_definition_from_float, { buffer = true, silent = true })
            vim.keymap.set('n', '<space>D', function()
                local word = vim.fn.expand('<cword>')
                for _, w in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_is_valid(w) then
                        local ok, cfg = pcall(vim.api.nvim_win_get_config, w)
                        if ok and cfg.relative ~= "" then
                            vim.api.nvim_win_close(w, false)
                        end
                    end
                end
                vim.fn.search(word, 'w')
                vim.lsp.buf.type_definition()
            end, { buffer = true, silent = true })
        end
    end,
})

-- Configure LSP hover window size dynamically based on terminal size
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = "rounded",
        max_width = math.floor(vim.o.columns * 0.8),  -- 80% of terminal width
        max_height = math.floor(vim.o.lines * 0.5),   -- 50% of terminal height
    }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
        border = "rounded",
        max_width = math.floor(vim.o.columns * 0.8),
        max_height = math.floor(vim.o.lines * 0.3),   -- Signature help is usually shorter
    }
)

-- Configure diagnostic float windows with same styling
vim.diagnostic.config({
    float = {
        border = "rounded",
        max_width = math.floor(vim.o.columns * 0.8),
        max_height = math.floor(vim.o.lines * 0.4),
        source = "always",  -- Show source of diagnostic (e.g., "eslint", "typescript")
        header = "",        -- No header text
        prefix = "",        -- No prefix for each line
    },
})
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '[e', function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, opts)
vim.keymap.set('n', ']e', function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set("n", "<space>f", function()
        require("conform").format({ async = true, lsp_fallback = true })
    end, bufopts)
end

-- Automatically call on_attach when LSP attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        on_attach(client, args.buf)
    end,
})
