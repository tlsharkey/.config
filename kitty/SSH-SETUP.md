# Kitty SSH/Mosh Clone Setup

## How It Works

**Session-Based Tracking**: Each kitty window gets its own session file that tracks SSH commands.

### The Flow

1. **Type SSH command** in Window 1 → preexec hook captures it
2. **Store** → Saves to `/tmp/kitty-ssh-sessions/$KITTY_WINDOW_ID`
3. **Press F6** → Creates Window 2, passes parent's window ID
4. **Lookup** → Window 2 looks up parent's session file
5. **Pre-populate** → If SSH command found, uses `print -z` to pre-populate
6. **You control** → Press Enter to connect, or edit first

### Session Isolation

Each window tracks its own SSH command independently:
- Window 1 (ID: 123): `ssh server-a` → stores to `/tmp/kitty-ssh-sessions/123`
- Window 2 (ID: 456): `ssh server-b` → stores to `/tmp/kitty-ssh-sessions/456`
- Window 3 (ID: 789): Local work → no session file

When you press F6 in any window, it only reads THAT window's session.

## Setup Instructions

### 1. Add to your ~/.zshrc

Add this line anywhere in your `~/.zshrc`:

```bash
# Source kitty SSH session tracking
[[ -f ~/.config/kitty/ssh-session.zsh ]] && source ~/.config/kitty/ssh-session.zsh
```

### 2. Reload your shell

```bash
source ~/.zshrc
```

### 3. Reload kitty configuration

Press `Ctrl+Cmd+,` (macOS) or `Ctrl+Shift+F5`, or restart kitty.

## Testing

### Test 1: Basic SSH Clone
```bash
# Terminal 1
ssh somehost
# Once connected, press F6
# Expected: New split with "ssh somehost" pre-populated
```

### Test 2: Multiple Windows
```bash
# Window 1
ssh server-a

# Window 2  
ssh server-b

# Window 3
# (stay local, no SSH)

# Press F6 in Window 1 → Should show "ssh server-a"
# Press F6 in Window 2 → Should show "ssh server-b"
# Press F6 in Window 3 → Should show nothing (empty)
```

### Debug

Check if capture is working:
```bash
# After typing an SSH command
ls -la /tmp/kitty-ssh-sessions/
# Should see file named with your window ID

cat /tmp/kitty-ssh-sessions/$KITTY_WINDOW_ID
# Should show: ssh somehost
```

Check parent ID is passed:
```bash
# In a newly created split
echo $KITTY_PARENT_WINDOW_ID
# Should show parent's window ID number
```

## Files

- `~/.config/kitty/ssh-session.zsh` - Session tracking logic
- `/tmp/kitty-ssh-sessions/<window-id>` - Per-window session files
- `~/.config/kitty/kitty.conf` - Updated keybindings

## Key Bindings

| Key | Action | Behavior |
|-----|--------|----------|
| F5 | Horizontal split (below) | Clones parent SSH command |
| F6 | Vertical split (right) | Clones parent SSH command |
| F4 | Auto split | Clones parent SSH command |
| Cmd+T | New tab | Clones parent SSH command |
| Cmd+Enter | New window | No cloning (home dir) |
| F1 | New window in CWD | No cloning |

## Cleanup

Session files are automatically cleaned up when windows close.

To manually clean all session files:
```bash
rm -rf /tmp/kitty-ssh-sessions
```

## Advantages

✓ Per-window isolation - no cross-contamination  
✓ No remote server setup needed  
✓ Works with any server immediately  
✓ Simple file-based storage  
✓ Automatic cleanup  
✓ Works with ssh, mosh, and similar commands
