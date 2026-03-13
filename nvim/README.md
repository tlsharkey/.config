# Neovim Configuration

This is a Neovim configuration that uses `lazy.nvim` to manage plugins.

## Installation

1.  Clone this repository to `~/.config/nvim`.
2.  Install the required dependencies listed below.
3.  Launch Neovim. The plugins will be installed automatically.

## Required Dependencies

The following dependencies need to be installed for this configuration to work correctly.

### Core Requirements

#### Neovim 0.11.0+

**macOS (Homebrew):**

```bash
brew install neovim
```

**Ubuntu/Debian:**

```bash
# Install from unstable PPA for latest version
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim
```

**Other Linux:**
Download the latest appimage from [Neovim releases](https://github.com/neovim/neovim/releases)

#### Tree-sitter CLI (0.26.1+)

Required for syntax highlighting.

**Via npm (all platforms):**

```bash
npm install -g tree-sitter-cli
```

#### C Compiler

Required for compiling tree-sitter parsers.

**macOS:**

```bash
xcode-select --install
```

**Ubuntu/Debian:**

```bash
sudo apt install build-essential
```

### Essential Tools

These tools are required for core editor functionality.

#### ripgrep

Fast search tool used by Telescope for finding text in files.

**macOS:**

```bash
brew install ripgrep
```

**Ubuntu/Debian:**

```bash
sudo apt install ripgrep
```

#### fd

Fast file finder used by Telescope.

**macOS:**

```bash
brew install fd
```

**Ubuntu/Debian:**

```bash
sudo apt install fd-find
# Create symlink if needed
sudo ln -s $(which fdfind) /usr/local/bin/fd
```

#### universal-ctags

Used by `vim-gutentags` for code navigation and tag generation.

**macOS:**

```bash
brew install universal-ctags
```

**Ubuntu/Debian:**

```bash
sudo apt install universal-ctags
```

### Language-Specific Tools

#### C# Development (OmniSharp)

Required only if working with C# projects.

**macOS:**

```bash
brew install omnisharp
```

**Ubuntu/Debian:**

```bash
# Download from https://github.com/OmniSharp/omnisharp-roslyn/releases
# Or let Mason install it automatically
```

### Optional Features

#### LaTeX Support (vimtex)

Required only if writing LaTeX documents.

**macOS:**

```bash
# Install MacTeX (full distribution)
brew install --cask mactex-no-gui

# Or BasicTeX (minimal)
brew install --cask basictex
```

**Ubuntu/Debian:**

```bash
sudo apt install texlive-full
# Or for minimal install
sudo apt install texlive-latex-base texlive-latex-extra
```

#### PDF Viewer for LaTeX

**macOS (Skim - recommended):**

```bash
brew install --cask skim
```

**Linux:**

```bash
# Zathura (lightweight)
sudo apt install zathura

# Or Okular (feature-rich)
sudo apt install okular
```

#### Quarto Support

Required only for Quarto notebook files.

**macOS:**

```bash
brew install quarto
```

**Ubuntu/Debian:**

```bash
# Download from https://quarto.org/docs/get-started/
sudo apt install ./quarto-linux-amd64.deb
```

#### Image Pasting (img-paste.vim)

Required only for pasting images directly into markdown.

**macOS:**

```bash
brew install pngpaste
```

**Linux:**

```bash
sudo apt install xclip
```

### Font Installation

A Nerd Font is required for icons in the UI.

**Manual Installation (all platforms):**

1. Download a Nerd Font from https://www.nerdfonts.com/
2. Recommended: JetBrainsMono Nerd Font, FiraCode Nerd Font, or Hack Nerd Font
3. Install the font on your system
4. Configure your terminal to use the installed Nerd Font

**macOS (Homebrew):**

```bash
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```

**Ubuntu/Debian:**

```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo "JetBrains Mono Nerd Font Complete.ttf" \
  https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf
fc-cache -fv
```

### Quick Install Scripts

**macOS (all essential dependencies):**

```bash
brew install neovim ripgrep fd universal-ctags tree-sitter node
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```

**Ubuntu/Debian (all essential dependencies):**

```bash
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim ripgrep fd-find universal-ctags build-essential nodejs npm
npm install -g tree-sitter-cli
```

### Plugin Setup

Some plugins require additional setup after installation.

#### Codeium

The `codeium.nvim` plugin requires you to log in to your Codeium account. After the plugin is installed, you will be prompted to log in. You can also run the `:Codeium Auth` command to start the authentication process.

## Compatibility Notes

### nvim-treesitter API Changes

This configuration now uses the **new nvim-treesitter API** (v3.0+) which requires:

- Neovim 0.11.0 or later
- `tree-sitter-cli` installed (version 0.26.1 or later)

The old API (`require('nvim-treesitter.configs')`) has been replaced with:

- `require('nvim-treesitter').install()` for parser installation
- `vim.treesitter.start()` for enabling highlighting per filetype

If you're running on Ubuntu with an older Neovim version, you may need to use the previous commit which works with the legacy treesitter API.

## Keybindings

This configuration uses `,` (comma) as the leader key.

### General

| Shortcut     | Action                    | Mode                   |
| ------------ | ------------------------- | ---------------------- |
| `<C-s>`      | Save file                 | Normal, Insert, Visual |
| `<C-/>`      | Toggle comment            | Normal, Insert, Visual |
| `<leader>ss` | Strip trailing whitespace | Normal                 |
| `<leader>W`  | Save file as root (sudo)  | Normal                 |

### Indentation

| Shortcut | Action                | Mode   |
| -------- | --------------------- | ------ |
| `>`      | Indent selection      | Visual |
| `<`      | Unindent selection    | Visual |
| `>>`     | Indent current line   | Normal |
| `<<`     | Unindent current line | Normal |

> **Note:** `<Tab>` and `<Shift-Tab>` are reserved for code completion navigation in insert mode.

### Navigation & Search

| Shortcut      | Action                              | Mode   |
| ------------- | ----------------------------------- | ------ |
| `fe`          | Toggle Neo-tree (File Explorer)     | Normal |
| `<C-h/j/k/l>` | Navigate between windows            | Normal |
| `<leader>ff`  | Find files (Telescope)              | Normal |
| `<leader>fg`  | Live grep / Search text (Telescope) | Normal |
| `<leader>fb`  | List open buffers (Telescope)       | Normal |
| `<leader>fh`  | Help tags (Telescope)               | Normal |

### Code Intelligence (LSP & Gutentags)

| Shortcut                 | Action                                    | Mode   | Provider       |
| ------------------------ | ----------------------------------------- | ------ | -------------- |
| `gd`                     | **G**o to **D**efinition (Context-aware)  | Normal | LSP            |
| `gr`                     | **G**o to **R**eferences (Find all usage) | Normal | LSP            |
| `K`                      | Show hover information (Docs)             | Normal | LSP            |
| `<C-k>`                  | Signature help (Function parameters)      | Normal | LSP            |
| `<space>rn`              | Rename symbol (Project-wide)              | Normal | LSP            |
| `<space>ca`              | Code actions (Quick fixes)                | Normal | LSP            |
| `<space>f`               | Format buffer                             | Normal | `conform.nvim` |
| `<space>e`               | Open diagnostic float (View error)        | Normal | LSP            |
| `[d` / `]d`              | Previous / Next diagnostic (all levels)   | Normal | LSP            |
| `[e` / `]e`              | Previous / Next ERROR diagnostic only     | Normal | LSP            |
| `:Telescope diagnostics` | View all diagnostics                      | Normal | LSP            |
| `<C-]>`                  | Jump to definition (Static)               | Normal | Gutentags      |
| `<C-t>`                  | Jump back from definition                 | Normal | Gutentags      |

### Diagnostics Panel (Trouble)

| Shortcut      | Action                            | Mode   |
| ------------- | --------------------------------- | ------ |
| `<leader>xx`  | Toggle workspace diagnostics      | Normal |
| `<leader>xd`  | Toggle buffer diagnostics         | Normal |
| `<leader>xl`  | Toggle location list              | Normal |
| `<leader>xq`  | Toggle quickfix list              | Normal |

### AI Completion (Codeium)

| Shortcut      | Action            | Mode   |
| ------------- | ----------------- | ------ |
| `<C-Down>`    | Accept suggestion | Insert |
| `<C-Up>`      | Next suggestion   | Insert |
| `<C-S-Right>` | Accept word       | Insert |
| `<C-Right>`   | Accept line       | Insert |

### Keybinding Helper (Which-key)

| Shortcut    | Action                      | Mode   |
| ----------- | --------------------------- | ------ |
| `<leader>`  | Shows available keybindings | Normal |
| `<leader>?` | Show buffer-local keymaps   | Normal |

> **Note:** When you press `<leader>` (comma), which-key will automatically popup after a short delay showing all available commands.

## Usage & Features

### File Navigation

- **Neo-tree**: File explorer sidebar
  - Toggle with custom keymaps (check `lua/keymaps.lua`)
  - Navigate with `hjkl`, press `P` to preview files

- **Telescope**: Fuzzy finder
  - Find files, search text, browse git history
  - Configured to ignore build artifacts and dependencies

### Language Support

- **LSP**: Automatic language server support via Mason
  - JSON and C# (OmniSharp) pre-configured
  - Install additional servers with `:Mason`

- **Treesitter**: Syntax highlighting for many languages
  - Parsers auto-install on first use
  - Enhanced markdown rendering with `render-markdown.nvim`

### LaTeX Editing

- **VimTeX**: Comprehensive LaTeX support
  - `:VimtexCompile` to compile and auto-preview
  - PDF updates automatically on save
  - See [VimTeX docs](https://github.com/lervag/vimtex/blob/master/VISUALS.md) for keyboard shortcuts
  - `]]` / `[[` to navigate between sections

### Markdown Features

- **Follow links**: `<Ctrl> + <click>` to open links
- **Rich rendering**: Custom checkboxes and beautiful formatting
- **Image pasting**: Paste images directly with `img-paste.vim`
- **Quarto**: Full support for Quarto notebooks

### Code Navigation

- **vim-gutentags**: Automatic tag generation
  - Jump to definition with `<C-]>`
  - Jump back with `<C-t>`
  - Works with universal-ctags

### AI Assistance

- **Codeium**: AI-powered code completion
  - Accept suggestions: `<C-Down>`
  - Next suggestion: `<C-Up>`
  - Accept word: `<C-S-Right>`
  - Accept line: `<C-Right>`

### Version Control

- **diffview.nvim**: Advanced diff and merge tool
  - View diffs, resolve merge conflicts
  - Better than default git diff

## Troubleshooting

### Tree-sitter parser errors

If you see parser errors, try:

```vim
:TSUpdate
```

### LSP not working

1. Check if the language server is installed:
   ```vim
   :Mason
   ```
2. Check LSP status:
   ```vim
   :LspInfo
   ```

### Fonts not displaying correctly

Make sure your terminal is configured to use a Nerd Font. The font must be set in your terminal application's preferences, not just installed on your system.
