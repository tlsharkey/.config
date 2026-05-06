-- Automatic venv detection and kernel initialization for Jupyter/molten
local M = {}

-- Check if ipykernel is installed in the current Python environment
function M.check_ipykernel(python_path)
    local cmd = string.format('%s -c "import ipykernel; print(ipykernel.__version__)"', python_path)
    local handle = io.popen(cmd .. " 2>/dev/null")
    local result = handle:read("*a")
    local success = handle:close()
    return success and result ~= ""
end

-- Get the Python executable from the current venv or pipx jupyter
function M.get_python_path()
    -- Check for active venv (VIRTUAL_ENV environment variable)
    local venv = os.getenv("VIRTUAL_ENV")
    if venv then
        return venv .. "/bin/python3"
    end

    -- Check for venv in current working directory
    local cwd = vim.fn.getcwd()
    local venv_paths = {
        cwd .. "/venv/bin/python3",
        cwd .. "/.venv/bin/python3",
        cwd .. "/env/bin/python3",
    }

    for _, path in ipairs(venv_paths) do
        if vim.fn.filereadable(path) == 1 then
            return path
        end
    end

    -- Fall back to pipx jupyter Python (which has ipykernel installed)
    local pipx_jupyter = vim.fn.expand("~/.local/pipx/venvs/jupyter/bin/python3")
    if vim.fn.filereadable(pipx_jupyter) == 1 then
        return pipx_jupyter
    end

    -- Last resort: system Python (but warn user)
    return vim.fn.exepath("python3")
end

-- Get or create a kernel for the current venv
function M.get_or_create_kernel()
    local python_path = M.get_python_path()
    local is_venv = python_path:find("/venv/") or python_path:find("/.venv/") or os.getenv("VIRTUAL_ENV")

    -- Check if ipykernel is available
    if not M.check_ipykernel(python_path) then
        vim.notify(
            "⚠️  ipykernel not found in current environment:\n" ..
            python_path .. "\n\n" ..
            "Install with: pip install ipykernel\n" ..
            "Then run: python -m ipykernel install --user --name <kernel_name>",
            vim.log.levels.WARN
        )
        return nil
    end

    -- If using a venv, suggest creating a kernel for it
    if is_venv then
        local cwd = vim.fn.getcwd()
        local kernel_name = vim.fn.fnamemodify(cwd, ":t") -- Use directory name as kernel name

        -- Check if kernel exists
        local handle = io.popen("jupyter kernelspec list")
        local spec_list = handle:read("*a")
        handle:close()

        if not spec_list:find(kernel_name) then
            -- Kernel doesn't exist, offer to create it
            local response = vim.fn.confirm(
                string.format(
                    "Create Jupyter kernel for this venv?\n\nPython: %s\nKernel name: %s\n\nThis allows using your venv's packages in notebooks.",
                    python_path,
                    kernel_name
                ),
                "&Yes\n&No\n&Use default python3",
                1
            )

            if response == 1 then
                -- Create the kernel
                local cmd = string.format(
                    '%s -m ipykernel install --user --name %s --display-name "%s (venv)"',
                    python_path,
                    kernel_name,
                    kernel_name
                )
                vim.fn.system(cmd)
                vim.notify("✅ Created kernel: " .. kernel_name, vim.log.levels.INFO)
                return kernel_name
            elseif response == 3 then
                return "python3" -- Use default kernel
            else
                return nil -- User cancelled
            end
        else
            return kernel_name -- Kernel already exists
        end
    end

    -- Not in a venv, use default python3 kernel
    return "python3"
end

-- Initialize molten with the current venv
function M.init_molten()
    local kernel_name = M.get_or_create_kernel()
    if not kernel_name then
        return -- User cancelled or error occurred
    end

    local cwd = vim.fn.getcwd()
    local python_path = M.get_python_path()
    local is_venv = python_path:find("/venv/") or python_path:find("/.venv/") or os.getenv("VIRTUAL_ENV")

    -- Initialize molten with the selected kernel
    vim.cmd("MoltenInit " .. kernel_name)

    -- After kernel starts, automatically set the working directory
    vim.defer_fn(function()
        -- Silently execute setup code in the kernel
        local setup_code = string.format([[import os; os.chdir('%s')]], cwd)

        -- Use vim.fn.MoltenEvaluateArgument to execute code silently
        -- We wrap in pcall in case the function isn't available yet
        pcall(function()
            vim.fn.MoltenEvaluateArgument(setup_code)
        end)

        -- Notify quarto that the runner is ready
        pcall(function()
            -- This sets up quarto's runner for the current buffer
            require("quarto").activate()
        end)

        -- Show brief success notification
        vim.notify(
            string.format(
                "✅ Kernel ready: %s%s\n📁 CWD: %s",
                kernel_name,
                is_venv and " (venv)" or "",
                cwd
            ),
            vim.log.levels.INFO,
            { timeout = 2000 }
        )
    end, 1000)
end

-- Command to manually check current environment
function M.check_environment()
    local python_path = M.get_python_path()
    local has_ipykernel = M.check_ipykernel(python_path)
    local cwd = vim.fn.getcwd()

    local message = string.format([[
Current Environment:
  Python: %s
  ipykernel: %s
  CWD: %s
  VIRTUAL_ENV: %s
]],
        python_path,
        has_ipykernel and "✅ Installed" or "❌ Not found",
        cwd,
        os.getenv("VIRTUAL_ENV") or "Not set"
    )

    vim.notify(message, vim.log.levels.INFO)
end

return M
