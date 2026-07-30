#!/bin/zsh
# Find parent window ID by querying kitty's window list

# Get all windows and find the one that was created just before us
PARENT_ID=$(kitty @ ls 2>/dev/null | grep -B 20 "\"id\": $KITTY_WINDOW_ID" | grep '"id":' | tail -2 | head -1 | grep -oE '[0-9]+')

export KITTY_PARENT_WINDOW_ID="$PARENT_ID"
echo "DEBUG: My ID=$KITTY_WINDOW_ID, Found parent=$PARENT_ID"

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

exec zsh
