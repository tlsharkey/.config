#load script
fpath=(~/ $fpath)

#unalias all the alias(es) before set anything
unalias -m "*"

#default charset and language
LANG='en_US.UTF-8'
LC_ALL='en_US.UTF-8'
export LS_COLORS="di=01;93:"

# CSI u support
export KEYTIMEOUT=1
bindkey -e
bindkey "[1;9D" backward-word
bindkey "[1;9C" forward-word
bindkey "[1;5D" backward-word
bindkey "[1;5C" forward-word
bindkey "[3~" delete-char

#set default editor
export EDITOR='vim'

#GPG passphrase input workaround
export GPG_TTY=`tty`

#tmux color issue
alias tmux='\tmux -2'

#uniq unicode issue
alias uniq='LC_ALL=C uniq'

#homebrew
export PATH="/opt/homebrew/bin:$PATH"

## Completions
autoload -U compinit
compinit -C

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

###alias###

#ls
alias ls='ls --color=auto'

#grep
alias grep='\grep --color=auto'
alias fgrep='\fgrep --color=auto'
alias egrep='\egrep --color=auto'

#network tool
alias ssh='ssh -F ~/.config/ssh/config -R 2222:localhost:22'
alias scp='scp -F ~/.config/ssh/config'
alias rsync='rsync -e "ssh -F /Users/tlsharkey/.config/ssh/config"'

#cd
alias cd..='\cd ..'
alias cd...='\cd ../..'
alias ..='\cd ..'
alias ...='\cd ../..'
alias ....='\cd ../../..'
alias .....='\cd ../../../..'

#other alias
alias sudo='\sudo -E'
alias less='\less -R'
alias df='\df -hT'
alias du='\du -h'
alias free='\free -h'
alias wgetncc='wget --no-check-certificate'
alias wget='wget --config ~/.config/wgetrc'
alias last='\last | less'
alias tree='\tree -C'
alias optipng='\optipng -o7 -zm1-9 -preserve'
alias vim='nvim'
alias python=python3
alias aider='aider --env-file ~/.config/aider.env'
# alias ctags = 'ctags --options=$HOME/.config/ctags'
alias defaultsource='source ~/.config/zshrc'
alias sourcedefault='source ~/.config/zshrc'
alias re-source='source ~/.config/zshrc'
alias resource='source ~/.config/zshrc'
alias .config='cd ~/.config'
alias tailscale='/Applications/Tailscale.app/Contents/MacOS/Tailscale'
# ollama
alias llm='ollama run gemma2:latest you are a smart command prompt that converts regular language into zsh script for macos. Whatever you say will be immediately entered into a terminal. respond in plain shell text. no markdown, no code blocks, no explanations. Just do the following prompt: '
# Youtube DL
alias yt-dlp="~/Applications/yt-dlp/.venv/bin/yt-dlp"
alias yt-dl="yt-dlp"

# Azure
autoload bashcompinit && bashcompinit
source $(brew --prefix)/etc/bash_completion.d/az

# Perl git lib
export PERLLIB=/Library/Developer/CommandLineTools/usr/share/git-core/perl:$PERLLIB

# Add git branch if its present to PS1
function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

function check_python_venv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo $VIRTUAL_ENV | grep -oE "[^\/\\]+$"
    fi
}

# cats the ssh config file where it matches a given host
function sshcat() {
    local search_pattern="$1"
    local config_files=()
    local main_configs=(~/.ssh/config ~/.config/ssh/config)

    # Collect all config files including imported ones
    for config in "${main_configs[@]}"; do
        if [[ -f "$config" ]]; then
            config_files+=("$config")
            # Find and add any included files
            while IFS= read -r include_line; do
                # Extract the path from Include directive
                local include_path=$(echo "$include_line" | sed -E 's/^[[:space:]]*Include[[:space:]]+//')
                # Expand ~ to home directory
                include_path="${include_path/#\~/$HOME}"
                # Handle wildcards
                for file in $~include_path; do
                    [[ -f "$file" ]] && config_files+=("$file")
                done
            done < <(grep -i '^[[:space:]]*Include' "$config" 2>/dev/null)
        fi
    done

    # Search all collected config files
    local found=false
    for config in "${config_files[@]}"; do
        local result=$(grep -iA6 "^[[:space:]]*Host[[:space:]].*$search_pattern" "$config" 2>/dev/null)
        if [[ -n "$result" ]]; then
            echo "# From: $config"
            echo "$result"
            echo ""
            found=true
        fi
    done

    if [[ "$found" = false ]]; then
        echo "No host matching '$search_pattern' found in SSH config files"
        return 1
    fi
}

setopt PROMPT_SUBST
export PROMPT='%F{grey}%n%f %F{cyan}%~%f %F{green}$(parse_git_branch)%f %F{normal}$%f '

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && \. "/usr/local/opt/nvm/etc/bash_completion"
# PNPM
export PNPM_HOME="/Users/tlsharkey/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export CODE_USER_DATA_DIR=~/.config/vscode


# merge in ~/.config/zshrc.private if it exists
[ -f ~/.config/zshrc.private ] && source ~/.config/zshrc.private

eval $(thefuck --alias)

# Azure
autoload bashcompinit && bashcompinit
source $(brew --prefix)/etc/bash_completion.d/az
export PATH="$HOME/.local/bin:$PATH"
