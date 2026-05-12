# Overwrite bashrc location
echo "source $HOME/.config/bashrc" >$HOME/.bash_profile
echo "source $HOME/.config/zshrc" >$HOME/.zshrc

# Overwrite git config location
echo "" >$HOME/.gitconfig
echo "[include]" >>$HOME/.gitconfig
echo "    path = $HOME/.config/git/gitconfig" >>$HOME/.gitconfig
# Git LFS
## MacOS
brew install git-lfs
## Ubuntu
sudo apt update
sudo apt upgrade
sudo apt install git-lfs

# Bat
## Ubuntu
sudo apt install bat
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat
## MacOS
brew install bat

# NEOVIM

## Ubuntu
sudo snap install nvim --classic
# dependencies
sudo apt install universal-ctags -y
sudo apt install build-essential -y
sudo apt install ripgrep -y
sudo apt install fd-find -y
sudo apt install unzip -y
sudo apt install golang-go -y
sudo apt install dotnet-sdk-8.0 -y
sudo apt install python3-venv -y
sudo apt install nodejs npm -y

## MacOS
brew install neovim
brew install universal-ctags
brew install ripgrep
brew install fd
brew install unzip
brew install go
brew install dotnet-sdk
# Create ctags config symlink
ln -sf ~/.config/ctags.d ~/.ctags.d
# for latex support: [skim](https://skim-app.sourceforge.io/)
# and [MaxTex](https://www.tug.org/mactex/mactex-download.html)
# for jupyter notebook support: [quarto](https://quarto.org/docs/get-started/)
# for pasting images: [xclip](https://github.com/astrand/xclip)
brew install xclip
brew install tree-sitter
brew install --cask mactex
# for image preview in markdown (optional - enables inline image rendering)
# there are two options here. One is the crossplatform ueberzugpp that has some jank:

## Fedora
sudo dnf install neovim
sudo dnf install golang
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

## MacOS
brew install ueberzugpp

## Fedora
sudo dnf install ueberzugpp

## Ubuntu/Debian (may need to build from source if not in repos)
# See: https://github.com/jstkdng/ueberzugpp
sudo apt install libvips-dev libsixel-dev chafa
git clone https://github.com/jstkdng/ueberzugpp.git /tmp/ueberzugpp
cd /tmp/ueberzugpp
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build .
sudo cmake --install .

### the other markdown image preview option is to use a kitty terminal
brew install luarocks imagemagick
luarocks install --local magick
luarocks search magick --porcelain

## Common - Jupyter Notebook Support
# Install jupytext for .ipynb to text conversion
pipx install jupytext

# Install Jupyter with molten-nvim dependencies
pipx install --include-deps jupyter
pipx inject jupyter pynvim ipykernel cairosvg pnglatex plotly kaleido pyperclip

# Create Neovim Python environment for pynvim provider
python3 -m venv ~/.config/nvim/.venv
~/.config/nvim/.venv/bin/pip install pynvim jupyter-client

# Install Python kernel globally (discoverable by all environments)
~/.local/pipx/venvs/jupyter/bin/python3 -m ipykernel install --user --name python3 --display-name "Python 3"

# Verify kernel installation
jupyter kernelspec list

## Lazygit
# macos
brew install Lazygit
# Fedora
sudo dnf copr enable dejan/lazygit
sudo dnf install Lazygit
# Ubuntu
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

# Node Version Manager
NVM_INSTALL_OUTPUT=$(curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh" | bash)
echo "$NVM_INSTALL_OUTPUT" | tail -n 4 | tee -a "$HOME/.config/bashrc.private" "$HOME/.config/zshrc.private" >/dev/null

# Docker
## Ubuntu
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update

## MacOS - install docker desktop from https://docs.docker.com/desktop/setup/install/mac-install/

# AWS cli
sudo snap install aws-cli --classic
## MacOS
cd ~/Downloads
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg ./AWSCLIV2.pkg -target /

# Azure cli
# MacOS
brew install azure-cli

# ls-tree
brew install tree
# bash completions
brew install bash-completion
# thefuck
brew thefuck install cjson cmake gcc coreutils gh go imath
# fedora
# install pyenv
curl -fsSL https://pyenv.run | bash
# update bashrc with path
pyenv install 3.11
pyenv global system 3.11.x
sudo dnf install pipx
pipx ensurepath # may need to add force and add to bashrc
pipx install thefuck --python python3.11

# Youtube-DLP
$()$(
    zsh
    cd ~/Applications
    mkdir yt-dlp
    cd yt-dlp
    python -m venv venv
    source venv/bin/activate
    pip install yt-dlp

    echo "alias yt-dlp='~/Applications/yt-dlp/venv/bin/yt-dlp'" >>~/.zshrc
)$()
or on ubuntu
$()$(
    bash
    cd ~/.local/bin
    mkdir yt-dlp
    cd yt-dlp
    python3 -m venv venv
    source venv/bin/activate
    pip install yt-dlp

    echo "alias yt-dlp='~/.local/bin/yt-dlp/venv/bin/yt-dlp'" >>~/.bashrc
)$()

## Claude or other agents tool
curl -fsSL https://claude.ai/install.sh | bash
# use agency-agents files
git clone https://github.com/msitarzewski/agency-agents ~/.claude/agents

## 1 Password Setup

# MacOS
ln -s ~/Library/Application\ Support/1Password/agent.sock ~/.1Password/agent.sock ~/.1password/agent.sock
# or update ~/.config/ssh/config IdentityFile to ~/Library/Application\ Support/1Password/agent.sock

## Signed Git Commits
Go into 1password, find the git signing key and select the option to sign git commits using 1password. Copy the text into ~/.gitconfig or ~/.config/git/gitconfig.private

## Make ping, rsync, scp all use ssh config host names
