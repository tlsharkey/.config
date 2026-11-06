#!/usr/bin/env sh
# Dispatcher: launches launch-with-parent.zsh or launch-with-parent.bash
# depending on which shell is available on the system.
# Exits cleanly (does nothing) if neither zsh nor bash is installed.

# First argument is the parent window ID
export KITTY_PARENT_WINDOW_ID="$1"

if command -v zsh >/dev/null 2>&1; then
    exec zsh "$HOME/.config/kitty/launch-with-parent.zsh" "$KITTY_PARENT_WINDOW_ID"
elif command -v bash >/dev/null 2>&1; then
    exec bash "$HOME/.config/kitty/launch-with-parent.bash" "$KITTY_PARENT_WINDOW_ID"
else
    exit 0
fi
