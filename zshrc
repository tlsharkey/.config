#load script
fpath=(~/ $fpath)

#unalias all the alias(es) before set anything
unalias -m "*"

#default charset and language
LANG='en_US.UTF-8'
LC_ALL='en_US.UTF-8'
export LS_COLORS="di=01;93:"

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
# ollama
alias llm='ollama run gemma3:12b you are a smart command prompt that converts regular language into zsh script for macos. Whatever you say will be immediately entered into a terminal. respond in plain shell text. no markdown, no code blocks, no explanations. Just do the following prompt: '


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
    local hostinfo=$(grep -A6 "$1" ~/.config/ssh/config)
    echo "$hostinfo"
}

setopt PROMPT_SUBST
export PROMPT='%F{grey}%n%f %F{cyan}%~%f %F{green}$(parse_git_branch)%f %F{normal}$%f '

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && \. "/usr/local/opt/nvm/etc/bash_completion"


export CODE_USER_DATA_DIR=~/.config/vscode

