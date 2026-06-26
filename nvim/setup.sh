#!/bin/bash
#
# Neovim Configuration Setup Script
# Sets up all dependencies for the Neovim configuration
#

set -e  # Exit on error

echo "🚀 Neovim Configuration Setup"
echo "=============================="
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ -f /etc/fedora-release ]]; then
    OS="fedora"
elif [[ -f /etc/debian_version ]]; then
    OS="debian"
else
    OS="unknown"
fi

echo "Detected OS: $OS"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages based on OS
install_packages() {
    case $OS in
        macos)
            echo "📦 Installing packages via Homebrew..."
            brew install "$@"
            ;;
        debian)
            echo "📦 Installing packages via apt..."
            sudo apt update
            sudo apt install -y "$@"
            ;;
        fedora)
            echo "📦 Installing packages via dnf..."
            sudo dnf install -y "$@"
            ;;
        *)
            echo "⚠️  Unknown OS. Please install manually: $@"
            return 1
            ;;
    esac
}

# Core dependencies
echo "1️⃣  Checking core dependencies..."
echo ""

# Neovim
if ! command_exists nvim; then
    echo "Installing Neovim..."
    case $OS in
        macos)
            install_packages neovim
            ;;
        debian)
            sudo add-apt-repository -y ppa:neovim-ppa/unstable
            install_packages neovim
            ;;
        fedora)
            install_packages neovim
            ;;
    esac
else
    echo "✅ Neovim already installed ($(nvim --version | head -1))"
fi

# Ripgrep
if ! command_exists rg; then
    echo "Installing ripgrep..."
    install_packages ripgrep
else
    echo "✅ ripgrep already installed"
fi

# fd
if ! command_exists fd; then
    echo "Installing fd..."
    case $OS in
        macos)
            install_packages fd
            ;;
        debian)
            install_packages fd-find
            sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
            ;;
        fedora)
            install_packages fd-find
            ;;
    esac
else
    echo "✅ fd already installed"
fi

# universal-ctags
if ! command_exists ctags; then
    echo "Installing universal-ctags..."
    install_packages universal-ctags
else
    echo "✅ universal-ctags already installed"
fi

echo ""
echo "2️⃣  Setting up tree-sitter..."
echo ""

# Create tree-sitter wrapper (avoids global npm install)
mkdir -p ~/.local/bin
if [[ ! -f ~/.local/bin/tree-sitter ]]; then
    cat > ~/.local/bin/tree-sitter << 'EOF'
#!/bin/bash
npx --yes tree-sitter-cli "$@"
EOF
    chmod +x ~/.local/bin/tree-sitter
    echo "✅ tree-sitter wrapper created at ~/.local/bin/tree-sitter"
else
    echo "✅ tree-sitter wrapper already exists"
fi

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo ""
    echo "⚠️  ~/.local/bin is not in your PATH!"
    echo "   Add this to your ~/.zshrc or ~/.bashrc:"
    echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

echo ""
echo "3️⃣  Setting up Ollama for AI assistance..."
echo ""

# Check if Ollama is installed
OLLAMA_PATH="/usr/local/bin/ollama"
if [[ ! -L "$OLLAMA_PATH" ]] && [[ ! -f "$OLLAMA_PATH" ]]; then
    echo "⚠️  Ollama not found in PATH"
    echo "   Install from: https://ollama.com"
    echo "   Or run: brew install --cask ollama"
    echo ""

    # Check if Ollama.app exists
    if [[ -d "/Applications/Ollama.app" ]]; then
        echo "✅ Ollama.app found in /Applications"
        echo "   Creating symlink to /usr/local/bin/ollama..."
        sudo ln -sf /Applications/Ollama.app/Contents/Resources/ollama /usr/local/bin/ollama
        echo "✅ Symlink created"
    fi
else
    echo "✅ Ollama found at $OLLAMA_PATH"
fi

# Check if Ollama is running
if command_exists ollama; then
    echo ""
    echo "Checking Ollama service..."
    if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
        echo "✅ Ollama service is running"

        # Check for installed models
        echo ""
        echo "Installed Ollama models:"
        ollama list

        # Suggest code models if none installed
        if ! ollama list 2>/dev/null | grep -qE "gemma|qwen|deepseek|codellama"; then
            echo ""
            echo "💡 Tip: Install a code-capable model for Avante.nvim:"
            echo "   ollama pull gemma4:26b       # Balanced (17GB)"
            echo "   ollama pull qwen2.5-coder    # Recommended"
            echo "   ollama pull deepseek-coder   # Fast"
            echo ""
        fi
    else
        echo "⚠️  Ollama service not running"
        echo "   Start with: ollama serve"
        echo "   Or launch Ollama.app from Applications"
    fi
fi

echo ""
echo "4️⃣  Optional dependencies..."
echo ""

# Font
echo "Checking Nerd Font installation..."
if [[ $OS == "macos" ]]; then
    if fc-list 2>/dev/null | grep -i "nerd" >/dev/null; then
        echo "✅ Nerd Font detected"
    else
        echo "💡 Install a Nerd Font for icons:"
        echo "   brew install --cask font-jetbrains-mono-nerd-font"
    fi
fi

# imagemagick for markdown image rendering
if ! command_exists magick && ! command_exists convert; then
    echo "💡 Install imagemagick for markdown image rendering:"
    case $OS in
        macos)
            echo "   brew install imagemagick"
            ;;
        debian|fedora)
            echo "   sudo apt/dnf install imagemagick"
            ;;
    esac
else
    echo "✅ imagemagick installed"
fi

echo ""
echo "5️⃣  Finalizing setup..."
echo ""

# Ensure /usr/local/bin is in PATH for Ollama
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
    echo "⚠️  /usr/local/bin is not in your PATH!"
    echo "   Add this to your ~/.zshrc or ~/.bashrc:"
    echo "   export PATH=\"/usr/local/bin:\$PATH\""
    echo ""
fi

# Create ctags symlink
if [[ ! -L ~/.ctags.d ]] && [[ -d ~/.config/ctags.d ]]; then
    ln -sf ~/.config/ctags.d ~/.ctags.d
    echo "✅ Created ctags config symlink"
fi

echo ""
echo "✨ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Restart your shell (or run: source ~/.zshrc)"
echo "   2. Launch Neovim: nvim"
echo "   3. Plugins will auto-install on first launch"
echo "   4. Avante.nvim will build native components (takes ~30 seconds)"
echo "   5. Try AI assistance: :AvanteChat"
echo ""
echo "📚 Documentation: ~/.config/nvim/README.md"
echo ""
