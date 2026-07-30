#!/bin/zsh
# Kitty SSH session tracking - associates SSH commands with kitty window IDs

# Only run if in kitty
if [[ -n "$KITTY_WINDOW_ID" ]]; then
    # Session storage directory
    SSH_SESSION_DIR="/tmp/kitty-ssh-sessions"
    mkdir -p "$SSH_SESSION_DIR"

    echo "🐱 Kitty SSH tracking loaded for window $KITTY_WINDOW_ID"

    # Hook that runs BEFORE each command executes
    function _kitty_capture_ssh() {
        local cmd="$1"

        # Check if command starts with ssh or mosh
        if [[ "$cmd" =~ ^(ssh|mosh)[[:space:]] ]]; then
            # Store command associated with this window ID
            echo "$cmd" > "$SSH_SESSION_DIR/$KITTY_WINDOW_ID"
            echo "✅ CAPTURED: '$cmd' → $SSH_SESSION_DIR/$KITTY_WINDOW_ID"
            echo "   Window ID: $KITTY_WINDOW_ID"
        fi
    }

    # Register the preexec hook
    autoload -Uz add-zsh-hook
    add-zsh-hook preexec _kitty_capture_ssh

    # On new shell startup, check if we have a parent session with SSH
    # This runs when a NEW window/split/tab is created
    if [[ -n "$KITTY_PARENT_WINDOW_ID" ]]; then
        echo "🔍 NEW WINDOW - Looking for parent's SSH command"
        echo "   My window ID: $KITTY_WINDOW_ID"
        echo "   Parent window ID: $KITTY_PARENT_WINDOW_ID"

        # Look up parent's SSH command
        local parent_ssh_file="$SSH_SESSION_DIR/$KITTY_PARENT_WINDOW_ID"
        echo "   Looking in: $parent_ssh_file"

        if [[ -f "$parent_ssh_file" ]]; then
            local ssh_cmd="$(cat "$parent_ssh_file")"
            echo "   ✅ FOUND: '$ssh_cmd'"
            echo "   Pre-populating command line..."
            # Pre-populate the command line without executing
            print -z "$ssh_cmd"
        else
            echo "   ❌ NOT FOUND - parent has no SSH session"
        fi
    else
        echo "ℹ️  No parent window ID - this is a fresh window"
    fi

    # Cleanup: Remove session file when window closes
    function _kitty_cleanup_ssh_session() {
        rm -f "$SSH_SESSION_DIR/$KITTY_WINDOW_ID"
    }
    add-zsh-hook zshexit _kitty_cleanup_ssh_session
fi
