-- Cross-platform TeX toolchain discovery for VimTeX.
--
-- TeX binaries are regularly missing from the environment Neovim inherits. On
-- macOS, /Library/TeX/texbin only reaches PATH through path_helper in login
-- shells, so a non-login terminal (or a GUI-launched editor) never sees it, and
-- an upstream TeX Live install drops its binaries into
-- <prefix>/<release>/bin/<arch> on every platform. VimTeX needs those binaries
-- both to pass its enable check and to spawn the latexmk job, so PATH is fixed
-- up here, before the plugin specs in plugins.lua are evaluated.

local M = {}

local ENGINES = { "latexmk", "pdflatex", "xelatex", "lualatex", "latex" }

-- Viewer modules that ship with VimTeX and support SyncTeX, in preference order.
local INTEGRATED_VIEWERS = { "skim", "sioyek", "zathura", "mupdf" }

-- Viewers with no VimTeX module of their own. Older VimTeX releases had
-- evince/okular viewers; today they must be driven through the general viewer,
-- which opens the document but cannot sync to the cursor line.
local FALLBACK_VIEWERS = { "okular", "evince" }

-- macOS viewers that install as an application bundle. VimTeX talks to Skim via
-- osascript, so the bundle is the real requirement: the optional `skim` command
-- line tool is NOT installed by `brew install --cask skim`.
local VIEWER_BUNDLES = { skim = "Skim", sioyek = "sioyek" }

local initialized = false
local warned_no_tex = false

local function is_windows()
    return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

-- executable() is not consistent about appending .exe on Windows.
local function is_executable(path)
    if vim.fn.executable(path) == 1 then
        return true
    end
    return is_windows() and vim.fn.executable(path .. ".exe") == 1
end

--- TeX Live lays binaries out as <root>/<release>/bin/<arch>; glob the
--- architecture instead of naming it, so x86_64-linux, aarch64-linux,
--- universal-darwin and windows all resolve without platform branches.
local function texlive_bin_dirs(root)
    local dirs = vim.fn.glob(root .. "/*/bin/*", true, true)
    -- glob() sorts alphabetically, so walk backwards to prefer newest release.
    local newest_first = {}
    for i = #dirs, 1, -1 do
        newest_first[#newest_first + 1] = dirs[i]
    end
    return newest_first
end

local function candidate_dirs()
    local dirs = {}

    -- Escape hatch for non-standard installs: module files, Nix profiles, or a
    -- custom --prefix passed to install-tl.
    if vim.env.TEX_BIN_DIR and vim.env.TEX_BIN_DIR ~= "" then
        dirs[#dirs + 1] = vim.env.TEX_BIN_DIR
    end

    -- MacTeX and BasicTeX maintain this stable symlink; it does not exist on
    -- Linux, where distro packages are already on PATH.
    dirs[#dirs + 1] = "/Library/TeX/texbin"

    for _, root in ipairs({ "/usr/local/texlive", "/opt/texlive", "C:/texlive" }) do
        for _, dir in ipairs(texlive_bin_dirs(root)) do
            dirs[#dirs + 1] = dir
        end
    end

    if is_windows() then
        local localappdata = vim.env.LOCALAPPDATA or ""
        dirs[#dirs + 1] = localappdata .. "/Programs/MiKTeX/miktex/bin/x64"
        dirs[#dirs + 1] = "C:/Program Files/MiKTeX/miktex/bin/x64"
    end

    return dirs
end

--- First directory on disk that actually holds a TeX engine, or nil.
local function discover_bin_dir()
    local seen = {}
    for _, dir in ipairs(candidate_dirs()) do
        if dir ~= "" and not seen[dir] and vim.fn.isdirectory(dir) == 1 then
            seen[dir] = true
            for _, engine in ipairs(ENGINES) do
                if is_executable(dir .. "/" .. engine) then
                    return dir
                end
            end
        end
    end
    return nil
end

--- True when a TeX engine is reachable through the current PATH.
function M.engine_on_path()
    for _, engine in ipairs(ENGINES) do
        if is_executable(engine) then
            return true
        end
    end
    return false
end

--- Put a discovered TeX bin directory on PATH. Idempotent, and safe to call
--- before the plugin specs are read.
function M.setup()
    if initialized then
        return
    end
    initialized = true

    if M.engine_on_path() then
        return
    end

    local dir = discover_bin_dir()
    if dir then
        local sep = is_windows() and ";" or ":"
        vim.env.PATH = dir .. sep .. (vim.env.PATH or "")
        M.bin_dir = dir
        return
    end

    -- Nothing found. VimTeX will stay unloaded, so replace that silence with one
    -- explanation when the user next opens a TeX file.
    local group = vim.api.nvim_create_augroup("LatexToolchain", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        desc = "Warn once when a TeX buffer opens without a TeX toolchain",
        group = group,
        pattern = { "tex", "latex", "plaintex" },
        callback = function()
            if warned_no_tex then
                vim.api.nvim_clear_autocmds({ group = group })
                return
            end
            warned_no_tex = true
            vim.notify(
                "VimTeX disabled: no TeX engine on PATH and nothing found in the usual "
                    .. "install locations. Install TeX Live/MacTeX, or set TEX_BIN_DIR to the "
                    .. "bin directory of a non-standard install.",
                vim.log.levels.WARN,
                { title = "VimTeX" }
            )
        end,
    })
end

--- Gate for the VimTeX plugin spec.
function M.has_tex()
    if not initialized then
        M.setup()
    end
    return M.engine_on_path()
end

local function viewer_available(viewer)
    if vim.fn.executable(viewer) == 1 then
        return true
    end
    local bundle = VIEWER_BUNDLES[viewer]
    return bundle ~= nil and vim.fn.isdirectory("/Applications/" .. bundle .. ".app") == 1
end

--- Returns a VimTeX view method, plus a command name when the general viewer is
--- needed. Returning nil leaves the choice to VimTeX, whose own defaults are
--- correct for Windows (SumatraPDF when present) and for a bare macOS install
--- (open, which hands the PDF to the default application).
function M.detect_viewer()
    if is_windows() then
        return nil
    end

    for _, viewer in ipairs(INTEGRATED_VIEWERS) do
        if viewer_available(viewer) then
            return viewer
        end
    end

    for _, viewer in ipairs(FALLBACK_VIEWERS) do
        if vim.fn.executable(viewer) == 1 then
            return "general", viewer
        end
    end

    return nil
end

return M
