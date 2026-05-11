-- Cell detection and execution for molten-nvim
-- Handles # %% style cells in Python files
local M = {}

-- Detect if we're in a cell-based file
function M.is_cell_based()
    local ft = vim.bo.filetype
    return ft == "python" or ft == "julia" or ft == "r"
end

-- Find the boundaries of the current cell
function M.get_cell_range()
    local current_line = vim.fn.line(".")
    local total_lines = vim.fn.line("$")

    -- Find start of cell (look backwards for # %%)
    local start_line = 1
    for i = current_line, 1, -1 do
        local line = vim.fn.getline(i)
        if line:match("^#%s*%%%%") then
            start_line = i + 1 -- Start after the cell marker
            break
        end
    end

    -- Find end of cell (look forwards for next # %% or end of file)
    local end_line = total_lines
    for i = current_line + 1, total_lines do
        local line = vim.fn.getline(i)
        if line:match("^#%s*%%%%") then
            end_line = i - 1 -- End before next cell marker
            break
        end
    end

    -- Trim empty lines at start and end
    while start_line <= end_line do
        local line = vim.fn.getline(start_line)
        if line:match("%S") then break end
        start_line = start_line + 1
    end

    while end_line >= start_line do
        local line = vim.fn.getline(end_line)
        if line:match("%S") then break end
        end_line = end_line - 1
    end

    return start_line, end_line
end

-- Execute the current cell
function M.run_cell()
    if not M.is_cell_based() then
        -- Fall back to quarto for markdown/quarto files
        require("quarto.runner").run_cell()
        return
    end

    local start_line, end_line = M.get_cell_range()

    if start_line > end_line then
        vim.notify("Empty cell", vim.log.levels.WARN)
        return
    end

    -- Get the cell content
    local lines = vim.fn.getline(start_line, end_line)
    local code = table.concat(lines, "\n")

    -- Execute via molten
    vim.fn.MoltenEvaluateRange(start_line, end_line)
end

-- Jump to next cell
function M.next_cell()
    local current_line = vim.fn.line(".")
    local total_lines = vim.fn.line("$")

    -- Find next # %%
    for i = current_line + 1, total_lines do
        local line = vim.fn.getline(i)
        if line:match("^#%s*%%%%") then
            vim.fn.cursor(i, 1)
            return
        end
    end

    vim.notify("No more cells below", vim.log.levels.INFO)
end

-- Jump to previous cell
function M.prev_cell()
    local current_line = vim.fn.line(".")

    -- Find previous # %%
    for i = current_line - 1, 1, -1 do
        local line = vim.fn.getline(i)
        if line:match("^#%s*%%%%") then
            vim.fn.cursor(i, 1)
            return
        end
    end

    vim.notify("No more cells above", vim.log.levels.INFO)
end

return M
