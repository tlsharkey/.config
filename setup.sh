# Overwrite bashrc location
echo "source $HOME/.config/bashrc" > $HOME/.bash_profile

# Overwrite git config location
echo "" > $HOME/.gitconfig
echo "[include]" >> $HOME/.gitconfig
echo "    path = $HOME/.config/git/gitconfig" >> $HOME/.gitconfig
# Git LFS
# MacOS
brew install git-lfs
# Ubuntu
sudo apt update
sudo apt upgrade
sudo apt install git-lfs

# Bat
sudo apt install bat
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

# NEOVIM
sudo snap install nvim --classic
# or
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
# dependencies
sudo apt install exuberant-ctags
sudo apt install build-essential
# xclip for pasting in images

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
echo "$NVM_INSTALL_OUTPUT" | tail -n 4 | tee -a "$HOME/.config/bashrc.private" "$HOME/.config/zshrc.private" > /dev/null

# Docker
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# AWS cli
sudo snap install aws-cli --classic
