require("bufferline").setup({
    options = {
        mode = "buffers",
        separator_style = "thin",
        indicator = {
            style = "none",
        },
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 18,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
        end,
        hover = {
            enabled = false,
            delay = 200,
            reveal = { "close" },
        },
        offsets = {
            {
                filetype = "neo-tree",
                text = "File Explorer",
                text_align = "center",
                separator = true,
            },
        },
    },
    highlights = {
        buffer_selected = {
            bold = true,
            italic = false,
        },
        separator = {
            fg = "#aaaaaa",
        },
        separator_visible = {
            bg = "NONE",
            fg = "#3b4261",
        },
        error = {
            fg = "#aa0000",
        },
        close_button = {
            fg = "#666666",
        },
    },
})
