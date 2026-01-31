#!/bin/bash
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc


###alias###
alias cat='bat'
alias open='gnome-open'
#ls
alias ls='ls --color=auto'
alias fzf='fzf --preview "bat --color=always {}"'

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
alias resource='source ~/.config/bashrc'
alias re-source='source ~/.config/bashrc'
# ollama alias for asking a question
alias ?=ollama_run
alias aider='aider --model ollama_chat/phi4 --env-file ~/.config/aider.env'

# AI Stuff
ollama_run() {
    local base_prompt="you are a smart command prompt that assists a user primarily with bash script on fedora. When appropriate only respond in the command line code corresponding to the users query. respond in plain shell text. Output will be set to a markdown renderer. Avoid explanations unless requested, especially long ones."
    local user_input="$*"
    combined_input="SYSTEM PROMPT: ${base_prompt} USER INPUT: ${user_input}"
    output=$(ollama run phi4:latest "$combined_input")
    # echo "$output"
    echo "$output" | glow
}

# Function to get the current git branch
parse_git_branch() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo "[$(git branch 2>/dev/null | grep '*' | sed 's/* //')] "
    else
        echo ""
    fi
}

# Custom prompt
PS1='\[\e[0;37m\]' # white color
PS1+='\u@\h ' # user@host
PS1+='\[\e[0;36m\]' # cyan color
PS1+='\w ' # cwd
PS1+='\[\e[0;37m\]' # white color
PS1+='\[\e[0;32m\]' # green color
PS1+='$(parse_git_branch)' # [branch]
PS1+='\[\e[0;37m\]' # white color
PS1+='\$ '
export PS1

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && \. "/usr/local/opt/nvm/etc/bash_completion"

export CODE_USER_DATA_DIR=~/.config/vscode
export OLLAMA_API_BASE=http://127.0.0.1:11434

