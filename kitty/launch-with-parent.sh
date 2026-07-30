#!/bin/zsh
# Launch wrapper that receives parent window ID as argument

# First argument is the parent window ID
export KITTY_PARENT_WINDOW_ID="$1"

# Check for Python venv in current directory and parent directories
check_and_activate_venv() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/venv/bin/activate" ]]; then
            export KITTY_VENV_PATH="$dir/venv"
            return 0
        elif [[ -f "$dir/.venv/bin/activate" ]]; then
            export KITTY_VENV_PATH="$dir/.venv"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Detect venv and export path if found
check_and_activate_venv

# Launch the shell
exec zsh
