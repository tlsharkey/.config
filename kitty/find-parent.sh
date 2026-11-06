#!/usr/bin/env sh
# Dispatcher: launches find-parent.zsh or find-parent.bash
# depending on which shell is available on the system.
# Exits cleanly (does nothing) if neither zsh nor bash is installed.

if command -v zsh >/dev/null 2>&1; then
    exec zsh "$HOME/.config/kitty/find-parent.zsh"
elif command -v bash >/dev/null 2>&1; then
    exec bash "$HOME/.config/kitty/find-parent.bash"
else
    exit 0
fi
