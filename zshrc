#!/bin/zsh
#load script
fpath=(~/ $fpath)

#unalias all the alias(es) before set anything
unalias -m "*"

#default charset and language
LANG='en_US.UTF-8'
LC_ALL='en_US.UTF-8'

#set default editor
export EDITOR='vim'

#GPG passphrase input workaround
export GPG_TTY=`tty`

#tmux color issue
alias tmux='\tmux -2'

#uniq unicode issue
alias uniq='LC_ALL=C uniq'

## Completions
autoload -U compinit
compinit -C

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

###alias###

#ls
alias l='ls -C'
alias ll='ls -lh'
alias la='ls -A'
alias lal='ls -lha'
alias ls='ls --color=auto'
alias fzf='fzf --preview "bat --color=always {}"'

#grep
alias g='\grep --color=auto'
alias grep='\grep --color=auto'
alias fgrep='\fgrep --color=auto'
alias egrep='\egrep --color=auto'
alias grep='grep --color=auto'

#network tool
alias p='ping'
alias n='nslookup'
alias d='dig'
alias t='mtr'
alias ssh='ssh -F ~/.config/ssh/config -R 2222:localhost:22'

#cd
alias cd..='\cd ..'
alias cd...='\cd ../..'
alias ..='\cd ..'
alias ...='\cd ../..'
alias ....='\cd ../../..'
alias .....='\cd ../../../..'

#other alias
alias c='clear'
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
alias cat='bat'

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

setopt PROMPT_SUBST
export PROMPT='%F{grey}%n%f %F{cyan}%~%f %F{green}$(parse_git_branch)%f %F{normal}$%f '

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && \. "/usr/local/opt/nvm/etc/bash_completion"

alias python=python3

export CODE_USER_DATA_DIR=~/.config/vscode

# Aider
alias aider='aider --env-file ~/.config/aider.env'

# tags
# alias ctags = 'ctags --options=$HOME/.config/ctags'


alias defaultsource='source ~/.config/zshrc'
alias sourcedefault='source ~/.config/zshrc'
alias re-source='source ~/.config/zshrc'
alias resource='source ~/.config/zshrc'
alias .config='cd ~/.config'
