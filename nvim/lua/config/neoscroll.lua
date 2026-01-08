return {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
        local neoscroll = require("neoscroll")

        neoscroll.setup({
            mappings = {},                      -- disable default mappings
            hide_cursor = false,            -- don't hide cursor
            stop_eof = true,                    -- stop at end of file
            respect_scrolloff = true, -- respect scrolloff
            cursor_scrolls_alone = false,
            easing_function = "quadratic",
        })

        -- Basic 1 visual line smooth scroll
        vim.keymap.set({ "n", "v", "x" }, "<C-e>", function()
            neoscroll.scroll(1, { move_cursor = false, duration = 200 })
        end, { silent = true, desc = "Scroll down one visual line" })

        vim.keymap.set({ "n", "v", "x" }, "<C-y>", function()
            neoscroll.scroll(-1, { move_cursor = false, duration = 200 })
        end, { silent = true, desc = "Scroll up one visual line" })

        -- Half-page / full-page scrolling
        vim.keymap.set("n", "<C-d>", function()
            neoscroll.scroll(0.5, { move_cursor = true, duration = 300 }) -- 50% of screen
        end, { silent = true })

        vim.keymap.set("n", "<C-u>", function()
            neoscroll.scroll(-0.5, { move_cursor = true, duration = 300 })
        end, { silent = true })

        vim.keymap.set("n", "<C-f>", function()
            neoscroll.scroll(1.0, { move_cursor = true, duration = 400 }) -- full screen
        end, { silent = true })

        vim.keymap.set("n", "<C-b>", function()
            neoscroll.scroll(-1.0, { move_cursor = true, duration = 400 })
        end, { silent = true })

        -- Trackpad / mouse wheel smooth scrolling
        -- Map <ScrollWheelUp> / <ScrollWheelDown> (xterm compatible)
        vim.keymap.set("n", "<ScrollWheelUp>", function()
            neoscroll.scroll(-0.25, { move_cursor = false, duration = 150 }) -- quarter line
        end, { silent = true })
        vim.keymap.set("n", "<ScrollWheelDown>", function()
            neoscroll.scroll(0.25, { move_cursor = false, duration = 150 })
        end, { silent = true })

        -- Also support visual mode scrolling for trackpad
        vim.keymap.set("v", "<ScrollWheelUp>", function()
            neoscroll.scroll(-0.25, { move_cursor = false, duration = 150 })
        end, { silent = true })

        vim.keymap.set("v", "<ScrollWheelDown>", function()
            neoscroll.scroll(0.25, { move_cursor = false, duration = 150 })
        end, { silent = true })
    end,
}
